-- Migration: Add water_goal_ml column to profiles table
-- Cel dzienny picia wody w ml (obliczany z wagi: np. 35 ml/kg)

ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS water_goal_ml DECIMAL(6,0) 
CHECK (water_goal_ml >= 500 AND water_goal_ml <= 10000);

COMMENT ON COLUMN profiles.water_goal_ml IS 'Dzienny cel picia wody w ml (np. obliczony 35 ml/kg lub ustawiony ręcznie)';
