-- Dodanie kolumny water_goal_ml do tabeli profiles
-- Domyślna wartość 2000 ml
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS water_goal_ml DECIMAL(6,2) DEFAULT 2000;
