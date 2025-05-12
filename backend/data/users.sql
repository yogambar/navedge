CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    clerk_id TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (clerk_id, email, password_hash) VALUES
('2480', 'navedge@gmail.com', 'hashed_Navedge@2480'),
('0248', 'tester@gmail.com', 'hashed_Tester@0248');

