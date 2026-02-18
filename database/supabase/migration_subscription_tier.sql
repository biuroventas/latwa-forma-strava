-- Subskrypcja: tier i data wygaśnięcia w profiles
-- Wykonaj w Supabase SQL Editor, jeśli kolumn jeszcze nie ma.

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_tier VARCHAR(20) NOT NULL DEFAULT 'free'
CHECK (subscription_tier IN ('free', 'premium'));

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN profiles.subscription_tier IS 'Plan: free lub premium';
COMMENT ON COLUMN profiles.subscription_expires_at IS 'Data wygaśnięcia Premium (null = bez limitu)';
