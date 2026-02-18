-- Tabela profiles - profil użytkownika
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
  age INTEGER NOT NULL CHECK (age >= 13 AND age <= 100),
  height_cm DECIMAL(5,2) NOT NULL CHECK (height_cm >= 100 AND height_cm <= 250),
  current_weight_kg DECIMAL(5,2) NOT NULL CHECK (current_weight_kg >= 30 AND current_weight_kg <= 300),
  target_weight_kg DECIMAL(5,2) NOT NULL CHECK (target_weight_kg >= 30 AND target_weight_kg <= 300),
  activity_level VARCHAR(20) NOT NULL CHECK (activity_level IN ('sedentary', 'light', 'moderate', 'intense', 'very_intense')),
  goal VARCHAR(20) NOT NULL CHECK (goal IN ('weight_loss', 'weight_gain', 'maintain')),
  bmr DECIMAL(8,2),
  tdee DECIMAL(8,2),
  target_calories DECIMAL(8,2),
  target_protein_g DECIMAL(6,2),
  target_fat_g DECIMAL(6,2),
  target_carbs_g DECIMAL(6,2),
  target_date DATE,
  weekly_weight_change DECIMAL(4,2) CHECK (weekly_weight_change >= 0 AND weekly_weight_change <= 2.0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela meals - posiłki
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  calories DECIMAL(8,2) NOT NULL CHECK (calories >= 0),
  protein_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (protein_g >= 0),
  fat_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (fat_g >= 0),
  carbs_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (carbs_g >= 0),
  weight_g DECIMAL(6,2),
  meal_type VARCHAR(20) CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
  source VARCHAR(20) NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'barcode', 'ingredients', 'ai_photo')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela activities - aktywności fizyczne
CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  calories_burned DECIMAL(8,2) NOT NULL CHECK (calories_burned >= 0),
  duration_minutes INTEGER CHECK (duration_minutes > 0),
  intensity VARCHAR(20) CHECK (intensity IN ('low', 'moderate', 'high', 'very_high')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela water_logs - logi wody
CREATE TABLE IF NOT EXISTS water_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount_ml DECIMAL(6,2) NOT NULL CHECK (amount_ml > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela weight_logs - logi wagi
CREATE TABLE IF NOT EXISTS weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  weight_kg DECIMAL(5,2) NOT NULL CHECK (weight_kg >= 30 AND weight_kg <= 300),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela body_measurements - pomiary ciała
CREATE TABLE IF NOT EXISTS body_measurements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  measurement_type VARCHAR(50) NOT NULL,
  value_cm DECIMAL(5,2) NOT NULL CHECK (value_cm > 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela favorite_meals - ulubione posiłki
CREATE TABLE IF NOT EXISTS favorite_meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  calories DECIMAL(8,2) NOT NULL CHECK (calories >= 0),
  protein_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (protein_g >= 0),
  fat_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (fat_g >= 0),
  carbs_g DECIMAL(6,2) NOT NULL DEFAULT 0 CHECK (carbs_g >= 0),
  ingredients JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela streaks - serie codziennych aktywności
CREATE TABLE IF NOT EXISTS streaks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  streak_type VARCHAR(20) NOT NULL CHECK (streak_type IN ('meals', 'water', 'activities', 'weight')),
  current_streak INTEGER NOT NULL DEFAULT 0 CHECK (current_streak >= 0),
  longest_streak INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak >= 0),
  last_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, streak_type)
);

-- Tabela goal_challenges - cele i wyzwania
CREATE TABLE IF NOT EXISTS goal_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type VARCHAR(30) NOT NULL CHECK (type IN ('weight_loss', 'calorie_deficit', 'water', 'exercise', 'streak')),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  target_value DECIMAL(10,2),
  current_value DECIMAL(10,2) DEFAULT 0,
  start_date DATE NOT NULL,
  end_date DATE,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabela goal_history - historia zmian celu
CREATE TABLE IF NOT EXISTS goal_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  old_target_calories DECIMAL(8,2),
  new_target_calories DECIMAL(8,2),
  old_target_date DATE,
  new_target_date DATE,
  old_weekly_weight_change DECIMAL(4,2),
  new_weekly_weight_change DECIMAL(4,2),
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indeksy dla lepszej wydajności
CREATE INDEX IF NOT EXISTS idx_meals_user_id ON meals(user_id);
CREATE INDEX IF NOT EXISTS idx_meals_created_at ON meals(created_at);
CREATE INDEX IF NOT EXISTS idx_activities_user_id ON activities(user_id);
CREATE INDEX IF NOT EXISTS idx_activities_created_at ON activities(created_at);
CREATE INDEX IF NOT EXISTS idx_water_logs_user_id ON water_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_water_logs_created_at ON water_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_weight_logs_user_id ON weight_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_weight_logs_created_at ON weight_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_body_measurements_user_id ON body_measurements(user_id);
CREATE INDEX IF NOT EXISTS idx_body_measurements_created_at ON body_measurements(created_at);
CREATE INDEX IF NOT EXISTS idx_favorite_meals_user_id ON favorite_meals(user_id);
CREATE INDEX IF NOT EXISTS idx_streaks_user_id ON streaks(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_challenges_user_id ON goal_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_challenges_type ON goal_challenges(type);
CREATE INDEX IF NOT EXISTS idx_goal_history_user_id ON goal_history(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_history_created_at ON goal_history(created_at);
