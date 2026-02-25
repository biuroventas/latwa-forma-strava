-- Migration: Add saturated fat, sugar, fiber, salt to meals (optional detailed macros)
-- Tłuszcze nasycone (część tłuszczów), cukry (część węglowodanów), błonnik, sól

ALTER TABLE meals
ADD COLUMN IF NOT EXISTS saturated_fat_g DECIMAL(6,2) DEFAULT 0 CHECK (saturated_fat_g >= 0),
ADD COLUMN IF NOT EXISTS sugar_g DECIMAL(6,2) DEFAULT 0 CHECK (sugar_g >= 0),
ADD COLUMN IF NOT EXISTS fiber_g DECIMAL(6,2) DEFAULT 0 CHECK (fiber_g >= 0),
ADD COLUMN IF NOT EXISTS salt_g DECIMAL(6,2) DEFAULT 0 CHECK (salt_g >= 0);

COMMENT ON COLUMN meals.saturated_fat_g IS 'Tłuszcze nasycone (g), część ogólnych tłuszczów';
COMMENT ON COLUMN meals.sugar_g IS 'Cukry (g), część węglowodanów';
COMMENT ON COLUMN meals.fiber_g IS 'Błonnik (g)';
COMMENT ON COLUMN meals.salt_g IS 'Sól (g)';
