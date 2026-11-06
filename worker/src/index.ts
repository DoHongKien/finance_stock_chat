import { Env, ChatRequestBody, ChatResponseBody } from './types';
import { DatabaseService } from './services/database';
import { SsiMcpClient } from './services/ssi_mcp_client';
import { GeminiService } from './services/gemini';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}

function errorResponse(message: string, status = 400): Response {
  return jsonResponse({ error: message }, status);
}

export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;
    const method = request.method;

    // 1. Xử lý CORS Preflight
    if (method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // 2. Kiểm tra Authentication Bearer Token (nếu có cấu hình secret)
    if (env.APP_CLIENT_SECRET && env.APP_CLIENT_SECRET.trim().length > 0) {
      const authHeader = request.headers.get('Authorization');
      const token = authHeader?.replace('Bearer ', '').trim();
      if (token !== env.APP_CLIENT_SECRET) {
        return errorResponse('Unauthorized: Invalid Client Secret', 401);
      }
    }

    const db = new DatabaseService(env.DB);
    const ssiToken = await db.getSetting('SSI_SESSION_TOKEN');
    const ssiClient = new SsiMcpClient(env.SSI_MCP_URL, ssiToken ?? undefined);
    const geminiService = new GeminiService(env.GEMINI_API_KEY, env.GEMINI_MODEL, ssiClient);

    try {
      // 3. Health Check
      if (path === '/' || path === '/api/health') {
        return jsonResponse({
          status: 'online',
          service: 'StockAI VN Cloudflare Worker',
          model: env.GEMINI_MODEL || 'gemini-2.0-flash',
          mcp_endpoint: env.SSI_MCP_URL,
          version: '1.0.0',
        });
      }

      // 4. API Chat: POST /api/chat
      if (path === '/api/chat' && method === 'POST') {
        const body = (await request.json()) as ChatRequestBody;
        const query = body.query?.trim();

        if (!query) {
          return errorResponse('Thiếu nội dung câu hỏi (query)');
        }

        const conversationId = body.conversation_id || crypto.randomUUID();

        // Đảm bảo phiên hội thoại tồn tại trong CSDL D1
        await db.ensureConversation(conversationId, query);

        // Lấy ngữ cảnh tin nhắn trước đó
        const history = await db.getMessages(conversationId, 6);

        // Lưu câu hỏi của người dùng vào D1
        await db.saveMessage(conversationId, 'user', query);

        // Kích hoạt Gemini 2.0 Flash với vòng lặp SSI MCP Tools
        const result = await geminiService.chatWithTools(query, history);

        // Lưu câu trả lời của trợ lý AI vào D1
        await db.saveMessage(conversationId, 'assistant', result.text, result.stockData);

        const responseData: ChatResponseBody = {
          content: result.text,
          conversation_id: conversationId,
          stock_data: result.stockData,
          follow_ups: result.followUps,
        };

        return jsonResponse(responseData);
      }

      // 5. API Watchlist: GET, POST, DELETE /api/watchlist
      if (path === '/api/watchlist') {
        if (method === 'GET') {
          const list = await db.getWatchlist();
          return jsonResponse({ items: list });
        }

        if (method === 'POST') {
          const body = (await request.json()) as {
            symbol: string;
            market?: string;
            note?: string;
            target_price?: number;
          };
          if (!body.symbol) {
            return errorResponse('Thiếu mã cổ phiếu (symbol)');
          }
          await db.addToWatchlist(body.symbol, body.market, body.note, body.target_price);
          return jsonResponse({ success: true, message: `Đã thêm ${body.symbol} vào watchlist` });
        }
      }

      if (path.startsWith('/api/watchlist/') && method === 'DELETE') {
        const symbol = path.split('/')[3];
        if (symbol) {
          await db.removeFromWatchlist(symbol);
          return jsonResponse({ success: true, message: `Đã xóa ${symbol} khỏi watchlist` });
        }
      }

      // 6. API Tổng quan thị trường: GET /api/market/overview
      if (path === '/api/market/overview' && method === 'GET') {
        const overview = await ssiClient.executeTool('get_market_overview', {});
        return jsonResponse({ overview });
      }

      // 7. API Tra cứu mã cổ phiếu trực tiếp: GET /api/stock/:symbol
      if (path.startsWith('/api/stock/') && method === 'GET') {
        const symbol = path.split('/')[2];
        if (!symbol) return errorResponse('Thiếu mã cổ phiếu');
        const quote = (await ssiClient.executeTool('get_stock_quote', { symbol })) as Record<string, unknown>;
        const stockData = ssiClient.createStockDataStructure(symbol, quote);
        return jsonResponse({ stock_data: stockData });
      }

      return errorResponse(`Không tìm thấy endpoint: ${method} ${path}`, 404);
    } catch (err: any) {
      console.error('[Worker Error]', err);
      return jsonResponse({ error: 'Lỗi xử lý máy chủ Worker', details: err?.message || String(err) }, 500);
    }
  },
};

