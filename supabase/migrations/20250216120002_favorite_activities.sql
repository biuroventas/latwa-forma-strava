-- Ulubione aktywności (szablony do szybkiego dodawania)
CREATE TABLE IF NOT EXISTS favorite_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  calories_burned DECIMAL(8,2) NOT NULL CHECK (calories_burned >= 0),
  duration_minutes INT CHECK (duration_minutes IS NULL OR duration_minutes > 0),
  intensity TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_favorite_activities_user_id ON favorite_activities(user_id);

ALTER TABLE favorite_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own favorite_activities"
  ON favorite_activities FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE favorite_activities IS 'Ulubione aktywności użytkownika – szablony do szybkiego dodawania';
