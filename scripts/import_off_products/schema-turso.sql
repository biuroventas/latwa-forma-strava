-- Tabela produktów dla Turso (SQLite). Uruchom: turso db shell <nazwa-bazy> < schema-turso.sql
CREATE TABLE IF NOT EXISTS products (
  barcode TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  name_pl TEXT,
  brand TEXT,
  calories_per_100g REAL NOT NULL DEFAULT 0,
  protein_g REAL NOT NULL DEFAULT 0,
  fat_g REAL NOT NULL DEFAULT 0,
  carbs_g REAL NOT NULL DEFAULT 0,
  weight_g REAL,
  image_url TEXT,
  ingredients TEXT,
  source TEXT DEFAULT 'off',
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_products_name ON products(name);
