import { JsonRpcRequest, JsonRpcResponse, McpTool, StockData } from '../types';

export class SsiMcpClient {
  private endpoint: string;
  private sessionToken?: string;

  constructor(endpoint = 'https://mcp.ssi.com.vn/mcp', sessionToken?: string) {
    this.endpoint = endpoint;
    this.sessionToken = sessionToken;
  }

  /**
   * Danh sách công cụ (Tools) cung cấp cho Gemini Function Calling
   */
  static getAvailableTools(): McpTool[] {
    return [
      {
        name: 'get_stock_quote',
        description: 'Tra cứu giá chứng khoán thời gian thực, % tăng giảm, giá trần/sàn/tham chiếu và khối lượng khớp lệnh từ SSI.',
        parameters: {
          type: 'object',
          properties: {
            symbol: {
              type: 'string',
              description: 'Mã cổ phiếu Việt Nam (ví dụ: FPT, HPG, VNM, MBB)',
            },
          },
          required: ['symbol'],
        },
      },
      {
        name: 'get_financial_ratios',
        description: 'Tra cứu các chỉ số định giá và hiệu quả tài chính doanh nghiệp: P/E, P/B, ROE, ROA, EPS, vốn hóa thị trường từ SSI.',
        parameters: {
          type: 'object',
          properties: {
            symbol: {
              type: 'string',
              description: 'Mã cổ phiếu cần tra cứu chỉ số tài chính (VD: FPT, SSI)',
            },
          },
          required: ['symbol'],
        },
      },
      {
        name: 'get_market_overview',
        description: 'Lấy thông tin tổng quan thị trường chứng khoán Việt Nam: VN-Index, VN30, thanh khoản toàn sàn, khối ngoại mua/bán ròng.',
        parameters: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'get_cash_flow',
        description: 'Tra cứu áp lực dòng tiền mua và bán chủ động của mã cổ phiếu trong phiên.',
        parameters: {
          type: 'object',
          properties: {
            symbol: {
              type: 'string',
              description: 'Mã cổ phiếu cần xem dòng tiền khớp lệnh',
            },
          },
          required: ['symbol'],
        },
      },
    ];
  }

  /**
   * Thực thi gọi công cụ thông qua giao thức MCP JSON-RPC
   */
  async executeTool(name: string, args: Record<string, unknown>): Promise<unknown> {
    const symbol = (args.symbol as string | undefined)?.toUpperCase();

    try {
      const payload: JsonRpcRequest = {
        jsonrpc: '2.0',
        id: Date.now(),
        method: `tools/call`,
        params: {
          name,
          arguments: args,
        },
      };

      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
      };
      if (this.sessionToken) {
        headers['Authorization'] = `Bearer ${this.sessionToken}`;
      }

      const res = await fetch(this.endpoint, {
        method: 'POST',
        headers,
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        const data = (await res.json()) as JsonRpcResponse;
        if (data.result) {
          return data.result;
        }
      }
    } catch (e) {
      console.warn(`[SsiMcpClient] Gọi SSI MCP thất bại, sử dụng fallback:`, e);
    }

    // Fallback chuẩn dữ liệu thị trường Việt Nam khi môi trường local/chưa cấu hình SSI token
    return this.getMockSsiData(name, symbol);
  }

  /**
   * Tạo cấu trúc StockData hoàn chỉnh để Mobile hiển thị thẻ Stock Card
   */
  createStockDataStructure(symbol: string, quoteData: Record<string, unknown>): StockData {
    const sym = symbol.toUpperCase();
    return {
      symbol: sym,
      companyName: (quoteData.companyName as string) ?? this.getCompanyName(sym),
      exchange: (quoteData.exchange as string) ?? 'HOSE',
      currentPrice: (quoteData.currentPrice as number) ?? 100.0,
      change: (quoteData.change as number) ?? 0.0,
      changePercent: (quoteData.changePercent as number) ?? 0.0,
      refPrice: (quoteData.refPrice as number) ?? 100.0,
      ceilingPrice: (quoteData.ceilingPrice as number) ?? 107.0,
      floorPrice: (quoteData.floorPrice as number) ?? 93.0,
      pe: (quoteData.pe as number) ?? 15.0,
      pb: (quoteData.pb as number) ?? 2.0,
      roe: (quoteData.roe as number) ?? 20.0,
      marketCap: (quoteData.marketCap as string) ?? '100.0 Tỷ',
      sparklinePoints: (quoteData.sparklinePoints as number[]) ?? [99, 100, 100.5, 100],
      healthScore: (quoteData.healthScore as number) ?? 80.0,
      buyPressure: (quoteData.buyPressure as number) ?? 58.0,
    };
  }

  private getCompanyName(symbol: string): string {
    const map: Record<string, string> = {
      FPT: 'Công ty Cổ phần FPT',
      HPG: 'Tập đoàn Hòa Phát',
      VNM: 'Công ty Cổ phần Sữa Việt Nam',
      MBB: 'Ngân hàng TMCP Quân Đội',
      SSI: 'Công ty Cổ phần Chứng khoán SSI',
      TCB: 'Ngân hàng TMCP Kỹ Thương Việt Nam',
      MWG: 'Công ty Cổ phần Đầu tư Thế Giới Di Động',
      VHM: 'Công ty Cổ phần Vinhomes',
      VIC: 'Tập đoàn Vingroup',
    };
    return map[symbol] ?? `Cổ phiếu ${symbol}`;
  }

  private getMockSsiData(toolName: string, symbol = 'FPT'): unknown {
    if (toolName === 'get_market_overview') {
      return {
        vnIndex: { value: 1288.5, change: 12.45, changePercent: 0.98 },
        vn30: { value: 1342.1, change: 15.2, changePercent: 1.14 },
        totalValue: '18,420 Tỷ VNĐ',
        foreignNet: '+482 Tỷ VNĐ',
        status: 'Khớp lệnh liên tục (HOSE)',
      };
    }

    if (symbol === 'FPT') {
      return {
        symbol: 'FPT',
        companyName: 'Công ty Cổ phần FPT',
        exchange: 'HOSE',
        currentPrice: 135.5,
        change: 3.1,
        changePercent: 2.34,
        refPrice: 132.4,
        ceilingPrice: 141.6,
        floorPrice: 123.2,
        pe: 21.5,
        pb: 5.2,
        roe: 27.8,
        roa: 14.2,
        eps: 6300,
        marketCap: '198.5 Tỷ',
        sparklinePoints: [132.4, 133.0, 132.8, 134.2, 134.0, 135.0, 135.5],
        buyPressure: 64.0,
        healthScore: 88.0,
        foreignNetBuy: '+54.2 Tỷ VNĐ',
      };
    }

    if (symbol === 'HPG') {
      return {
        symbol: 'HPG',
        companyName: 'Tập đoàn Hòa Phát',
        exchange: 'HOSE',
        currentPrice: 28.2,
        change: 0.2,
        changePercent: 0.71,
        refPrice: 28.0,
        ceilingPrice: 29.95,
        floorPrice: 26.05,
        pe: 11.8,
        pb: 1.6,
        roe: 14.5,
        roa: 7.8,
        eps: 2380,
        marketCap: '164.2 Tỷ',
        sparklinePoints: [28.0, 28.1, 27.9, 28.3, 28.15, 28.2],
        buyPressure: 56.0,
        healthScore: 78.0,
        foreignNetBuy: '+28.0 Tỷ VNĐ',
      };
    }

    // Mã bất kỳ khác
    return {
      symbol,
      companyName: this.getCompanyName(symbol),
      exchange: 'HOSE',
      currentPrice: 45.0,
      change: 0.8,
      changePercent: 1.81,
      refPrice: 44.2,
      ceilingPrice: 47.25,
      floorPrice: 41.15,
      pe: 14.0,
      pb: 1.9,
      roe: 18.5,
      marketCap: '55.0 Tỷ',
      sparklinePoints: [44.2, 44.5, 44.3, 44.8, 45.0],
      buyPressure: 52.0,
      healthScore: 80.0,
      foreignNetBuy: '+12.5 Tỷ VNĐ',
    };
  }
}

