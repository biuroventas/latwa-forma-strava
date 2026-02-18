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

CREATE INDEX IF NOT EXISTS idx_goal_history_user_id ON goal_history(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_history_created_at ON goal_history(created_at);
