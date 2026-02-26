-- Umożliwia wyłączenie aktywności z bilansu kalorii (np. nie liczyć wybranej aktywności z Garmin w „spalone”).
ALTER TABLE activities
  ADD COLUMN IF NOT EXISTS excluded_from_balance boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN activities.excluded_from_balance IS 'Jeśli true, aktywność nie wlicza się do „spalone” na dashboardzie.';
