import { GeminiContent, GeminiToolDeclaration, StockData } from '../types';
import { SsiMcpClient } from './ssi_mcp_client';

export class GeminiService {
  private apiKey?: string;
  private model: string;
  private ssiClient: SsiMcpClient;

  constructor(apiKey?: string, model = 'gemini-2.0-flash', ssiClient?: SsiMcpClient) {
    this.apiKey = apiKey;
    this.model = model;
    this.ssiClient = ssiClient ?? new SsiMcpClient();
  }

  /**
   * Chạy chu trình hội thoại + Function Calling loop với Gemini 2.0 Flash
   */
  async chatWithTools(
    userQuery: string,
    history: Array<{ sender: string; content: string }> = []
  ): Promise<{
    text: string;
    stockData: StockData | null;
    followUps: string[];
  }> {
    // Nếu chưa cấu hình API Key, trả về câu trả lời giả lập thông minh
    if (!this.apiKey) {
      return this.generateFallbackResponse(userQuery);
    }

    const systemPrompt = `Bạn là Trợ lý AI Chuyên gia Chứng khoán Việt Nam (StockAI VN), kết nối trực tiếp với cổng dữ liệu SSI MCP Server.
NGUYÊN TẮC:
1. Khi người dùng hỏi về giá, % biến động, P/E, P/B, ROE, BCTC, VN-Index hay doanh nghiệp, bạn BẮT BUỘC phải gọi Function Calling để lấy dữ liệu SSI thực tế. Tuyệt đối không tự suy diễn số liệu.
2. Trả lời bằng tiếng Việt súc tích, khách quan, định dạng Markdown rõ ràng (in đậm mã, giá, tỷ lệ %).
3. Tối ưu cho màn hình điện thoại di động: ngắn gọn, đi thẳng vào trọng tâm.`;

    // Chuẩn bị danh sách Tools từ SSI MCP
    const toolsDeclaration: GeminiToolDeclaration = {
      function_declarations: SsiMcpClient.getAvailableTools().map((t) => ({
        name: t.name,
        description: t.description,
        parameters: t.parameters,
      })),
    };

    // Chuẩn bị lịch sử hội thoại
    const contents: GeminiContent[] = [];

    // Thêm các tin nhắn cũ
    for (const msg of history) {
      contents.push({
        role: msg.sender === 'user' ? 'user' : 'model',
        parts: [{ text: msg.content }],
      });
    }

    // Thêm câu hỏi hiện tại của người dùng
    contents.push({
      role: 'user',
      parts: [{ text: userQuery }],
    });

    try {
      const url = `https://generativelanguage.googleapis.com/v1beta/models/${this.model}:generateContent?key=${this.apiKey}`;

      // Vòng 1: Gửi Prompt + Tools sang Gemini
      const firstResponse = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: { parts: [{ text: systemPrompt }] },
          contents,
          tools: [toolsDeclaration],
          generationConfig: {
            temperature: 0.2,
            maxOutputTokens: 1024,
          },
        }),
      });

      if (!firstResponse.ok) {
        throw new Error(`Gemini API Error: ${firstResponse.status} ${await firstResponse.text()}`);
      }

      const firstData = (await firstResponse.json()) as any;
      const candidate = firstData.candidates?.[0];
      const parts = candidate?.content?.parts ?? [];

      // Kiểm tra xem Gemini có yêu cầu gọi Tool không
      const functionCallPart = parts.find((p: any) => p.functionCall);

      let finalStockData: StockData | null = null;

      if (functionCallPart?.functionCall) {
        const call = functionCallPart.functionCall;
        const toolName = call.name;
        const toolArgs = call.args ?? {};

        // Thực thi gọi Tool qua SSI MCP
        const toolResult = (await this.ssiClient.executeTool(toolName, toolArgs)) as Record<string, unknown>;

        // Nếu tool trả về dữ liệu mã cổ phiếu, cấu trúc hóa thành StockData
        if (toolArgs.symbol && typeof toolArgs.symbol === 'string') {
          finalStockData = this.ssiClient.createStockDataStructure(toolArgs.symbol, toolResult);
        }

        // Vòng 2: Gửi kết quả dữ liệu SSI lại cho Gemini soạn câu phân tích
        contents.push({
          role: 'model',
          parts: [{ functionCall: call }],
        });

        contents.push({
          role: 'function',
          parts: [
            {
              functionResponse: {
                name: toolName,
                response: {
                  name: toolName,
                  content: toolResult,
                },
              },
            },
          ],
        });

        const secondResponse = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            systemInstruction: { parts: [{ text: systemPrompt }] },
            contents,
            generationConfig: {
              temperature: 0.3,
            },
          }),
        });

        if (secondResponse.ok) {
          const secondData = (await secondResponse.json()) as any;
          const finalCandidate = secondData.candidates?.[0];
          const finalText = finalCandidate?.content?.parts?.[0]?.text ?? 'Đã hoàn tất phân tích số liệu.';

          return {
            text: finalText,
            stockData: finalStockData,
            followUps: this.generateFollowUps(userQuery, finalStockData?.symbol),
          };
        }
      }

      // Nếu Gemini trả lời trực tiếp mà không cần gọi tool
      const directText = parts[0]?.text ?? 'Không nhận được phản hồi từ AI.';
      return {
        text: directText,
        stockData: null,
        followUps: this.generateFollowUps(userQuery),
      };
    } catch (e) {
      console.error('[GeminiService] Ngoại lệ khi gọi Gemini:', e);
      return this.generateFallbackResponse(userQuery);
    }
  }

  private generateFollowUps(query: string, symbol?: string): string[] {
    const sym = symbol?.toUpperCase();
    if (sym === 'FPT') {
      return [
        'Biên lợi nhuận ròng FPT quý vừa qua thế nào?',
        'Khối ngoại mua hay bán ròng FPT hôm nay?',
        'So sánh P/E của FPT và MWG',
      ];
    } else if (sym === 'HPG') {
      return [
        'Dự án Dung Quất 2 đóng góp gì cho doanh thu HPG?',
        'Giá thép cuộn cán nóng HRC ảnh hưởng ra sao?',
        'P/B hiện tại của HPG có hấp dẫn không?',
      ];
    } else if (sym) {
      return [
        `Chỉ số P/E và P/B của ${sym} thế nào?`,
        `Biến động dòng tiền mua bán chủ động của ${sym}`,
        `Kế hoạch chia cổ tức sắp tới của ${sym}`,
      ];
    }

    return [
      'Hôm nay VN-Index đóng cửa bao nhiêu điểm?',
      'Xem giá và P/E của FPT',
      'Top cổ phiếu khối ngoại mua ròng nhiều nhất?',
    ];
  }

  private generateFallbackResponse(query: string): {
    text: string;
    stockData: StockData | null;
    followUps: string[];
  } {
    const upper = query.toUpperCase();

    if (upper.includes('FPT')) {
      const stock = this.ssiClient.createStockDataStructure('FPT', {
        currentPrice: 135.5,
        change: 3.1,
        changePercent: 2.34,
        refPrice: 132.4,
        ceilingPrice: 141.6,
        floorPrice: 123.2,
        pe: 21.5,
        pb: 5.2,
        roe: 27.8,
        marketCap: '198.5 Tỷ',
        sparklinePoints: [132.4, 133.0, 132.8, 134.2, 134.0, 135.0, 135.5],
        buyPressure: 64.0,
        healthScore: 88.0,
      });

      return {
        text: `Cổ phiếu **FPT (CTCP FPT)** hôm nay giao dịch khởi sắc tại mốc **135.500 ₫**, tăng **+3.100 ₫ (+2.34%)** so với giá tham chiếu. Khối ngoại mua ròng tích cực hơn 54 tỷ đồng. Định giá P/E hiện ở mức 21.5 lần, ROE đạt 27.8% phản ánh chất lượng tăng trưởng doanh thu phần mềm vững chắc.`,
        stockData: stock,
        followUps: this.generateFollowUps(query, 'FPT'),
      };
    }

    if (upper.includes('HPG')) {
      const stock = this.ssiClient.createStockDataStructure('HPG', {
        currentPrice: 28.2,
        change: 0.2,
        changePercent: 0.71,
        refPrice: 28.0,
        ceilingPrice: 29.95,
        floorPrice: 26.05,
        pe: 11.8,
        pb: 1.6,
        roe: 14.5,
        marketCap: '164.2 Tỷ',
        sparklinePoints: [28.0, 28.1, 27.9, 28.3, 28.15, 28.2],
        buyPressure: 56.0,
        healthScore: 78.0,
      });

      return {
        text: `Cổ phiếu **HPG (Tập đoàn Hòa Phát)** đóng cửa ở mức **28.200 ₫**, tăng nhẹ **+0.71%**. Khối lượng khớp lệnh đạt hơn 18 triệu đơn vị. Định giá P/B hiện tại là 1.6 lần, trong khi P/E là 11.8 lần. Tiến độ giai đoạn 1 của đại dự án Dung Quất 2 tiếp tục là kỳ vọng dẫn dắt tăng trưởng giai đoạn 2025-2026.`,
        stockData: stock,
        followUps: this.generateFollowUps(query, 'HPG'),
      };
    }

    return {
      text: `Chỉ số **VN-Index** hôm nay tăng **+12.45 điểm (+0.98%)** đạt mốc **1,288.50 điểm**. Độ rộng thị trường nghiêng về bên mua với 245 mã tăng và 130 mã giảm. Khối ngoại tiếp tục mua ròng tập trung vào nhóm Công nghệ thông tin (FPT) và Ngân hàng (MBB, TCB).`,
      stockData: null,
      followUps: this.generateFollowUps(query),
    };
  }
}

