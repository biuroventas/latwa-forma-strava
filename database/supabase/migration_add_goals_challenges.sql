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

CREATE INDEX IF NOT EXISTS idx_goal_challenges_user_id ON goal_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_challenges_type ON goal_challenges(type);
