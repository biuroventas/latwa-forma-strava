-- Cofnięcie: usunięcie kolumny garmin_user_id (Data Viewer)
ALTER TABLE garmin_integrations
  DROP COLUMN IF EXISTS garmin_user_id;
