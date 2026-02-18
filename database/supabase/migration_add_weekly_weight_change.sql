-- Migration: Add weekly_weight_change column to profiles table
-- Execute this in Supabase SQL Editor if the column doesn't exist

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS weekly_weight_change DECIMAL(4,2) 
CHECK (weekly_weight_change >= 0 AND weekly_weight_change <= 2.0);

-- Add comment
COMMENT ON COLUMN profiles.weekly_weight_change IS 'Tempo zmiany wagi w kg/tydzień (0.1-1.5 dla chudnięcia, 0.1-0.5 dla przybierania)';
