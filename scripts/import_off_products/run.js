/**
 * Import Open Food Facts products (Polish subset) into Supabase `products` table.
 * Usage:
 *   1. Download: curl -o openfoodfacts-products.jsonl.gz https://static.openfoodfacts.org/data/openfoodfacts-products.jsonl.gz
 *   2. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY
 *   3. node run.js [path/to/openfoodfacts-products.jsonl.gz]
 *
 * Reads JSONL line by line (gzip), filters by countries_tags containing Poland and nutriments,
 * maps to products row, batch inserts. Limits to ~30k products to stay under 500MB.
 */

import { createReadStream } from 'fs';
import { createInterface } from 'readline';
import { createGunzip } from 'zlib';
import { createClient } from '@supabase/supabase-js';

const BATCH_SIZE = 500;
const MAX_PRODUCTS = 30_000;

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

function parseWeight(quantity) {
  if (!quantity || typeof quantity !== 'string') return null;
  const m = quantity.match(/(\d+(?:[.,]\d+)?)\s*g/i);
  return m ? parseFloat(m[1].replace(',', '.')) : null;
}

function rowFromProduct(p) {
  const nut = p.nutriments || {};
  let protein = nut.proteins_100g ?? nut.proteins;
  let fat = nut.fat_100g ?? nut.fat;
  let carbs = nut.carbohydrates_100g ?? nut.carbohydrates;
  let energyKcal = nut['energy-kcal_100g'] ?? nut['energy-kcal'];
  if (energyKcal == null) {
    const kj = nut['energy-kj_100g'] ?? nut['energy_100g'] ?? nut.energy_100g;
    if (kj != null) energyKcal = kj / 4.184;
  }
  if (energyKcal == null && (protein != null || fat != null || carbs != null)) {
    energyKcal = (Number(protein) || 0) * 4 + (Number(fat) || 0) * 9 + (Number(carbs) || 0) * 4;
  }
  const name = p.product_name || p.product_name_pl || p.product_name_en || 'Produkt';
  const barcode = String(p.code ?? '').trim();
  if (!barcode) return null;

  return {
    barcode,
    name: name.substring(0, 1000),
    name_pl: (p.product_name_pl || '').substring(0, 1000) || null,
    brand: (p.brands || '').substring(0, 500) || null,
    calories_per_100g: Number(energyKcal) || 0,
    protein_g: Number(protein) || 0,
    fat_g: Number(fat) || 0,
    carbs_g: Number(carbs) || 0,
    weight_g: parseWeight(p.quantity),
    image_url: (p.image_url || '').substring(0, 2000) || null,
    ingredients: (p.ingredients_text_pl || p.ingredients_text || '').substring(0, 5000) || null,
    source: 'off',
  };
}

function hasPoland(obj) {
  const tags = obj.countries_tags;
  if (Array.isArray(tags)) return tags.some((t) => t === 'en:poland');
  if (typeof tags === 'string') return tags.includes('en:poland');
  return false;
}

function hasNutriments(obj) {
  const nut = obj.nutriments;
  if (!nut || typeof nut !== 'object') return false;
  return (
    nut['energy-kcal_100g'] != null ||
    nut['energy-kj_100g'] != null ||
    nut.energy_100g != null ||
    nut.proteins_100g != null ||
    nut.fat_100g != null ||
    nut.carbohydrates_100g != null
  );
}

async function run() {
  const inputPath = process.argv[2] || 'openfoodfacts-products.jsonl.gz';
  console.log('Reading from', inputPath, '...');

  const fileStream = createReadStream(inputPath);
  const gunzip = createGunzip();
  fileStream.pipe(gunzip);
  const rl = createInterface({ input: gunzip, crlfDelay: Infinity });

  let batch = [];
  let total = 0;
  let skipped = 0;

  fileStream.on('error', (err) => {
    console.error('File error:', err.message);
    process.exit(1);
  });

  for await (const line of rl) {
    if (total >= MAX_PRODUCTS) break;
    const raw = line.trim();
    if (!raw) continue;
    let p;
    try {
      p = JSON.parse(raw);
    } catch {
      continue;
    }
    if (!hasPoland(p)) {
      skipped++;
      continue;
    }
    if (!hasNutriments(p)) {
      skipped++;
      continue;
    }
    const row = rowFromProduct(p);
    if (!row) continue;
    batch.push(row);
    if (batch.length >= BATCH_SIZE) {
      const { error } = await supabase.from('products').upsert(batch, {
        onConflict: 'barcode',
        ignoreDuplicates: false,
      });
      if (error) {
        console.error('Insert error:', error.message);
        process.exit(1);
      }
      total += batch.length;
      console.log('Inserted', total, 'products');
      batch = [];
    }
  }

  if (batch.length > 0) {
    const { error } = await supabase.from('products').upsert(batch, {
      onConflict: 'barcode',
      ignoreDuplicates: false,
    });
    if (error) {
      console.error('Insert error:', error.message);
      process.exit(1);
    }
    total += batch.length;
  }

  console.log('Done. Total products imported:', total);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
