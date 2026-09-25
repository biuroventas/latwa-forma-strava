/**
 * Import Open Food Facts (Polish subset) do bazy Turso (tabela products).
 * Wymagane: TURSO_DATABASE_URL (https://xxx.turso.io), TURSO_AUTH_TOKEN.
 * Najpierw utwórz tabelę: turso db shell <nazwa-bazy> < schema-turso.sql
 *
 * Użycie: node run-turso.js [path/to/openfoodfacts-products.jsonl.gz]
 */

import 'dotenv/config';
import { createReadStream } from 'fs';
import { createInterface } from 'readline';
import { createGunzip } from 'zlib';
import { createClient } from '@libsql/client';

const BATCH_SIZE = 500;
const MAX_PRODUCTS = 30_000;

const url = (process.env.TURSO_DATABASE_URL || process.env.TURSO_URL || '').trim();
const authToken = (process.env.TURSO_AUTH_TOKEN || '').trim();

if (!url || !authToken) {
  console.error('Ustaw TURSO_DATABASE_URL (lub TURSO_URL) oraz TURSO_AUTH_TOKEN');
  process.exit(1);
}

const client = createClient({ url, authToken });

const IMAGE_BASE = 'https://images.openfoodfacts.org/images/products';
const IMAGE_SIZE = '200'; // rozmiar miniatury dla listy (wysokość w px)

/**
 * Buduje URL zdjęcia produktu z obiektu images (eksport OFF JSONL).
 * Zgodnie z https://openfoodfacts.github.io/openfoodfacts-server/api/how-to-download-images/
 */
function imageUrlFromProduct(p) {
  const barcode = String(p.code ?? '').trim();
  if (!barcode) return null;
  const padded = barcode.padStart(13, '0');
  const m = padded.match(/^(...)(...)(...)(.*)$/);
  const folder = m ? `${m[1]}/${m[2]}/${m[3]}/${m[4]}` : padded;
  const base = `${IMAGE_BASE}/${folder}`;

  const directKeys = ['image_url', 'image_small_url', 'image_thumb_url', 'image_front_small_url'];
  for (const key of directKeys) {
    const v = p[key];
    if (typeof v === 'string' && v.startsWith('http')) return v.substring(0, 2000);
  }

  const images = p.images;
  if (!images || typeof images !== 'object') return null;

  const preferKeys = ['front_pl', 'front_en', 'front'];
  for (const key of preferKeys) {
    const sel = images[key];
    if (sel && sel.rev != null) {
      const rev = String(sel.rev);
      return `${base}/${key}.${rev}.${IMAGE_SIZE}.jpg`;
    }
  }
  for (const key of Object.keys(images)) {
    if (preferKeys.includes(key)) continue;
    const sel = images[key];
    if (sel && sel.rev != null) {
      const rev = String(sel.rev);
      return `${base}/${key}.${rev}.${IMAGE_SIZE}.jpg`;
    }
  }
  const numericKey = Object.keys(images).find((k) => /^\d+$/.test(k));
  if (numericKey) return `${base}/${numericKey}.${IMAGE_SIZE}.jpg`;
  return null;
}

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

  const imageUrl = imageUrlFromProduct(p);

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
    image_url: imageUrl ? imageUrl.substring(0, 2000) : null,
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

const INSERT_SQL = `INSERT OR REPLACE INTO products (barcode, name, name_pl, brand, calories_per_100g, protein_g, fat_g, carbs_g, weight_g, image_url, ingredients, source) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

async function run() {
  const inputPath = process.argv[2] || 'openfoodfacts-products.jsonl.gz';
  console.log('Reading from', inputPath, '...');

  const fileStream = createReadStream(inputPath);
  const gunzip = createGunzip();
  fileStream.pipe(gunzip);
  const rl = createInterface({ input: gunzip, crlfDelay: Infinity });

  let batch = [];
  let total = 0;

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
    if (!hasPoland(p)) continue;
    if (!hasNutriments(p)) continue;
    const row = rowFromProduct(p);
    if (!row) continue;
    batch.push(row);
    if (batch.length >= BATCH_SIZE) {
      const stmts = batch.map((r) => ({
        sql: INSERT_SQL,
        args: [
          r.barcode,
          r.name,
          r.name_pl ?? null,
          r.brand ?? null,
          r.calories_per_100g,
          r.protein_g,
          r.fat_g,
          r.carbs_g,
          r.weight_g ?? null,
          r.image_url ?? null,
          r.ingredients ?? null,
          r.source,
        ],
      }));
      await client.batch(stmts, 'write');
      total += batch.length;
      console.log('Inserted', total, 'products');
      batch = [];
    }
  }

  if (batch.length > 0) {
    const stmts = batch.map((r) => ({
      sql: INSERT_SQL,
      args: [
        r.barcode,
        r.name,
        r.name_pl ?? null,
        r.brand ?? null,
        r.calories_per_100g,
        r.protein_g,
        r.fat_g,
        r.carbs_g,
        r.weight_g ?? null,
        r.image_url ?? null,
        r.ingredients ?? null,
        r.source,
      ],
    }));
    await client.batch(stmts, 'write');
    total += batch.length;
  }

  console.log('Done. Total products imported:', total);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
