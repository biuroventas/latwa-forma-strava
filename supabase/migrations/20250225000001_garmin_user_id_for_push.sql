-- garmin_user_id potrzebne do mapowania push Garmin (userId z payloadu) na user_id w naszej bazie
ALTER TABLE garmin_integrations
  ADD COLUMN IF NOT EXISTS garmin_user_id TEXT;

CREATE INDEX IF NOT EXISTS idx_garmin_integrations_garmin_user_id
  ON garmin_integrations(garmin_user_id)
  WHERE garmin_user_id IS NOT NULL;

COMMENT ON COLUMN garmin_integrations.garmin_user_id IS 'Garmin Health API user id – do mapowania push payload (userId) na nasz user_id';
