export class DatabaseService {
  constructor(private db: D1Database) {}

  /**
   * Tạo hoặc cập nhật phiên trò chuyện
   */
  async ensureConversation(conversationId: string, firstQuery: string): Promise<void> {
    const title = firstQuery.slice(0, 40);
    await this.db
      .prepare(
        `INSERT INTO conversations (id, title, updated_at) 
         VALUES (?, ?, CURRENT_TIMESTAMP)
         ON CONFLICT(id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP`
      )
      .bind(conversationId, title)
      .run();
  }

  /**
   * Lưu tin nhắn hội thoại
   */
  async saveMessage(
    conversationId: string,
    sender: 'user' | 'assistant',
    content: string,
    structuredData?: unknown
  ): Promise<void> {
    const dataStr = structuredData ? JSON.stringify(structuredData) : null;
    await this.db
      .prepare(
        `INSERT INTO chat_messages (conversation_id, sender, content, structured_data) 
         VALUES (?, ?, ?, ?)`
      )
      .bind(conversationId, sender, content, dataStr)
      .run();
  }

  /**
   * Lấy lịch sử tin nhắn của một phiên hội thoại
   */
  async getMessages(conversationId: string, limit = 10): Promise<Array<{ sender: string; content: string }>> {
    const { results } = await this.db
      .prepare(
        `SELECT sender, content, structured_data, created_at 
         FROM chat_messages 
         WHERE conversation_id = ? 
         ORDER BY id ASC 
         LIMIT ?`
      )
      .bind(conversationId, limit)
      .all<{ sender: string; content: string; structured_data: string | null; created_at: string }>();

    return results ?? [];
  }

  /**
   * Lấy toàn bộ danh sách Watchlist
   */
  async getWatchlist(): Promise<Array<{ symbol: string; market: string; note: string | null; target_price: number | null }>> {
    const { results } = await this.db
      .prepare(`SELECT symbol, market, note, target_price FROM watchlist ORDER BY id DESC`)
      .all<{ symbol: string; market: string; note: string | null; target_price: number | null }>();

    return results ?? [];
  }

  /**
   * Thêm mã vào Watchlist
   */
  async addToWatchlist(symbol: string, market = 'HOSE', note?: string, targetPrice?: number): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO watchlist (symbol, market, note, target_price) 
         VALUES (?, ?, ?, ?)
         ON CONFLICT(symbol) DO UPDATE SET 
           note = coalesce(excluded.note, watchlist.note),
           target_price = coalesce(excluded.target_price, watchlist.target_price)`
      )
      .bind(symbol.toUpperCase(), market.toUpperCase(), note ?? null, targetPrice ?? null)
      .run();
  }

  /**
   * Xóa mã khỏi Watchlist
   */
  async removeFromWatchlist(symbol: string): Promise<void> {
    await this.db
      .prepare(`DELETE FROM watchlist WHERE UPPER(symbol) = UPPER(?)`)
      .bind(symbol)
      .run();
  }

  /**
   * Đọc cấu hình token hoặc setting
   */
  async getSetting(key: string): Promise<string | null> {
    const res = await this.db
      .prepare(`SELECT value FROM app_settings WHERE key = ?`)
      .bind(key)
      .first<{ value: string }>();
    return res?.value ?? null;
  }

  /**
   * Ghi cấu hình token hoặc setting
   */
  async setSetting(key: string, value: string): Promise<void> {
    await this.db
      .prepare(
        `INSERT INTO app_settings (key, value, updated_at) 
         VALUES (?, ?, CURRENT_TIMESTAMP)
         ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = CURRENT_TIMESTAMP`
      )
      .bind(key, value)
      .run();
  }
}

