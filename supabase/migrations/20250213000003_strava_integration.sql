-- Tabela integracji Strava (tokeny per użytkownik)
CREATE TABLE IF NOT EXISTS strava_integrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  refresh_token TEXT NOT NULL,
  access_token TEXT NOT NULL,
  expires_at BIGINT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id)
);

-- Indeks dla szybkiego wyszukiwania
CREATE INDEX IF NOT EXISTS idx_strava_integrations_user_id ON strava_integrations(user_id);

-- Tabela zsynchronizowanych aktywności Strava (unikamy duplikatów)
CREATE TABLE IF NOT EXISTS strava_synced_activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  strava_activity_id BIGINT NOT NULL,
  activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, strava_activity_id)
);

CREATE INDEX IF NOT EXISTS idx_strava_synced_user_strava_id ON strava_synced_activities(user_id, strava_activity_id);

-- RLS
ALTER TABLE strava_integrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE strava_synced_activities ENABLE ROW LEVEL SECURITY;

-- Użytkownik widzi/edytuje tylko swoje
DROP POLICY IF EXISTS strava_integrations_own ON strava_integrations;
CREATE POLICY strava_integrations_own ON strava_integrations
  FOR ALL USING (auth.uid() = user_id);

DROP POLICY IF EXISTS strava_synced_own ON strava_synced_activities;
CREATE POLICY strava_synced_own ON strava_synced_activities
  FOR ALL USING (auth.uid() = user_id);
