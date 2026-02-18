-- Migration: Allow custom measurement types (e.g. biceps) in body_measurements
-- Execute this in Supabase SQL Editor

-- Drop the CHECK constraint that limits measurement_type to predefined values
ALTER TABLE body_measurements 
DROP CONSTRAINT IF EXISTS body_measurements_measurement_type_check;

-- Allow longer custom names (e.g. "Biceps lewy")
ALTER TABLE body_measurements 
ALTER COLUMN measurement_type TYPE VARCHAR(50);
