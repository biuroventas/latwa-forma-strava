-- Identyfikator klienta Stripe (do portalu – zarządzanie / rezygnacja z subskrypcji).
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS stripe_customer_id TEXT;

COMMENT ON COLUMN profiles.stripe_customer_id IS 'Stripe Customer ID (cus_...) – do Billing Portal';
