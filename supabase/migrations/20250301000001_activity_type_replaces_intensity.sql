-- Zastąpienie kolumny intensity kolumną activity_type (typ aktywności, np. RUNNING z Garmin).
-- Zgodne z danymi z Garmin (activityType w pushu) i wyświetlaniem typu zamiast intensywności.

-- Tabela activities
ALTER TABLE activities ADD COLUMN IF NOT EXISTS activity_type TEXT;
UPDATE activities SET activity_type = intensity WHERE intensity IS NOT NULL;
ALTER TABLE activities DROP COLUMN IF EXISTS intensity;
COMMENT ON COLUMN activities.activity_type IS 'Typ aktywności, np. RUNNING, CYCLING (Garmin/Strava) lub low/moderate/high (stare wpisy).';

-- Tabela favorite_activities
ALTER TABLE favorite_activities ADD COLUMN IF NOT EXISTS activity_type TEXT;
UPDATE favorite_activities SET activity_type = intensity WHERE intensity IS NOT NULL;
ALTER TABLE favorite_activities DROP COLUMN IF EXISTS intensity;
COMMENT ON COLUMN favorite_activities.activity_type IS 'Typ aktywności (szablon).';
