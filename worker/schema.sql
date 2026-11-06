-- 1. Bảng danh mục cổ phiếu theo dõi (Watchlist)
CREATE TABLE IF NOT EXISTS watchlist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol TEXT NOT NULL UNIQUE,          -- Mã cổ phiếu (VD: FPT, HPG)
    market TEXT DEFAULT 'HOSE',           -- Sàn: HOSE, HNX, UPCOM
    target_price REAL,                    -- Giá mục tiêu kỳ vọng (nếu có)
    note TEXT,                            -- Ghi chú cá nhân
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng hội thoại (Conversations)
CREATE TABLE IF NOT EXISTS conversations (
    id TEXT PRIMARY KEY,                  -- UUID của phiên chat
    title TEXT NOT NULL,                  -- Tiêu đề tóm tắt (VD: "Hỏi về FPT & HPG")
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng tin nhắn (Chat Messages)
CREATE TABLE IF NOT EXISTS chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    conversation_id TEXT NOT NULL,
    sender TEXT NOT NULL CHECK(sender IN ('user', 'assistant')),
    content TEXT NOT NULL,                -- Nội dung phản hồi bằng chữ
    structured_data TEXT,                 -- Dữ liệu JSON chứa mã, giá, P/E (để render Card)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
);

-- 4. Bảng cấu hình & Token SSI
CREATE TABLE IF NOT EXISTS app_settings (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Dữ liệu mẫu khởi đầu cho Watchlist
INSERT OR IGNORE INTO watchlist (symbol, market, note) VALUES 
('FPT', 'HOSE', 'Cổ phiếu công nghệ đầu ngành'),
('HPG', 'HOSE', 'Thép Hòa Phát - Dung Quất 2'),
('MBB', 'HOSE', 'Ngân hàng Quân Đội');

