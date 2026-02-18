-- Dodanie pola subscription_tier do profiles (Free / Premium)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_tier VARCHAR(20) NOT NULL DEFAULT 'free'
  CHECK (subscription_tier IN ('free', 'premium'));

-- Opcjonalnie: data wygaśnięcia subskrypcji (dla przyszłej integracji z płatnościami)
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN profiles.subscription_tier IS 'free | premium';
COMMENT ON COLUMN profiles.subscription_expires_at IS 'Data wygaśnięcia subskrypcji premium (null = lifetime lub free)';
