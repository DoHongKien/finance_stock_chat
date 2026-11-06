export interface Env {
  DB: D1Database;
  GEMINI_API_KEY?: string;
  APP_CLIENT_SECRET?: string;
  SSI_MCP_URL: string;
  GEMINI_MODEL: string;
}

export interface StockData {
  symbol: string;
  companyName: string;
  exchange: string;
  currentPrice: number;
  change: number;
  changePercent: number;
  refPrice: number;
  ceilingPrice: number;
  floorPrice: number;
  pe: number;
  pb: number;
  roe: number;
  marketCap: string;
  sparklinePoints: number[];
  healthScore?: number;
  buyPressure?: number;
  industry?: string;
}

export interface ChatRequestBody {
  query: string;
  conversation_id?: string;
  locale?: string;
}

export interface ChatResponseBody {
  content: string;
  conversation_id: string;
  stock_data?: StockData | null;
  follow_ups: string[];
}

// Model Context Protocol (MCP) JSON-RPC Types
export interface McpTool {
  name: string;
  description: string;
  parameters: {
    type: 'object';
    properties: Record<string, {
      type: string;
      description: string;
      enum?: string[];
    }>;
    required?: string[];
  };
}

export interface JsonRpcRequest {
  jsonrpc: '2.0';
  id: string | number;
  method: string;
  params?: Record<string, unknown>;
}

export interface JsonRpcResponse<T = unknown> {
  jsonrpc: '2.0';
  id: string | number;
  result?: T;
  error?: {
    code: number;
    message: string;
    data?: unknown;
  };
}

// Gemini Types
export interface GeminiToolDeclaration {
  function_declarations: Array<{
    name: string;
    description: string;
    parameters: {
      type: string;
      properties: Record<string, unknown>;
      required?: string[];
    };
  }>;
}

export interface GeminiPart {
  text?: string;
  functionCall?: {
    name: string;
    args: Record<string, unknown>;
  };
  functionResponse?: {
    name: string;
    response: {
      name: string;
      content: unknown;
    };
  };
}

export interface GeminiContent {
  role: 'user' | 'model' | 'function';
  parts: GeminiPart[];
}

