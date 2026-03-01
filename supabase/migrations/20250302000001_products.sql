-- Katalog produktów (import z Open Food Facts + później user/restaurant)
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  barcode TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  name_pl TEXT,
  brand TEXT,
  calories_per_100g DECIMAL(8,2) NOT NULL DEFAULT 0,
  protein_g DECIMAL(6,2) NOT NULL DEFAULT 0,
  fat_g DECIMAL(6,2) NOT NULL DEFAULT 0,
  carbs_g DECIMAL(6,2) NOT NULL DEFAULT 0,
  weight_g DECIMAL(8,2),
  image_url TEXT,
  ingredients TEXT,
  source TEXT DEFAULT 'off',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_barcode ON products(barcode);
CREATE INDEX IF NOT EXISTS idx_products_name_lower ON products (lower(name));

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read products"
  ON products FOR SELECT
  TO authenticated
  USING (true);

COMMENT ON TABLE products IS 'Katalog produktów – import OFF (Polska), opcjonalnie user/restaurant';
COMMENT ON COLUMN products.source IS 'off | user | restaurant';
