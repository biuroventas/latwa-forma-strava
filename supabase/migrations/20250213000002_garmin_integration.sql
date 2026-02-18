-- Tabela integracji Garmin Connect (tokeny per użytkownik)
CREATE TABLE IF NOT EXISTS garmin_integrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  refresh_token TEXT,
  access_token TEXT NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_garmin_integrations_user_id ON garmin_integrations(user_id);

-- Tabela zsynchronizowanych aktywności Garmin (unikamy duplikatów)
CREATE TABLE IF NOT EXISTS garmin_synced_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  garmin_activity_id TEXT NOT NULL,
  activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, garmin_activity_id)
);

CREATE INDEX IF NOT EXISTS idx_garmin_synced_user_activity ON garmin_synced_activities(user_id, garmin_activity_id);

ALTER TABLE garmin_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE garmin_synced_activities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS garmin_integrations_own ON garmin_integrations;
CREATE POLICY garmin_integrations_own ON garmin_integrations
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS garmin_synced_own ON garmin_synced_activities;
CREATE POLICY garmin_synced_own ON garmin_synced_activities
  FOR ALL USING (auth.uid() = user_id);
