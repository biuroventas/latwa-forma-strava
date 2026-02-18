# Migracje bazy danych

## Wymagane migracje

Aby aplikacja działała poprawnie, musisz uruchomić następujące migracje w Supabase:

### 1. Migracja: goal_challenges i goal_history

Uruchom w SQL Editor w Supabase Dashboard:

```sql
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

-- Indeksy
CREATE INDEX IF NOT EXISTS idx_goal_challenges_user_id ON goal_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_challenges_type ON goal_challenges(type);
CREATE INDEX IF NOT EXISTS idx_goal_history_user_id ON goal_history(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_history_created_at ON goal_history(created_at);
```

### 2. RLS Policies (Row Level Security)

Po utworzeniu tabel, dodaj polityki RLS:

```sql
-- RLS dla goal_challenges
ALTER TABLE goal_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own goal_challenges"
  ON goal_challenges FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goal_challenges"
  ON goal_challenges FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goal_challenges"
  ON goal_challenges FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goal_challenges"
  ON goal_challenges FOR DELETE
  USING (auth.uid() = user_id);

-- RLS dla goal_history
ALTER TABLE goal_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own goal_history"
  ON goal_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goal_history"
  ON goal_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

### 3. Migracja: własne typy pomiarów ciała

Uruchom plik `migration_custom_measurement_type.sql` w SQL Editor, aby umożliwić wpisywanie własnych typów pomiarów (np. Biceps):

```sql
ALTER TABLE body_measurements 
DROP CONSTRAINT IF EXISTS body_measurements_measurement_type_check;

ALTER TABLE body_measurements 
ALTER COLUMN measurement_type TYPE VARCHAR(50);
```

## Jak uruchomić migracje

1. Otwórz Supabase Dashboard
2. Przejdź do **SQL Editor**
3. Skopiuj i wklej powyższe skrypty SQL
4. Uruchom każdy skrypt osobno (lub wszystkie razem)
5. Sprawdź czy tabele zostały utworzone w **Table Editor**

## Sprawdzenie

Po uruchomieniu migracji, sprawdź czy tabele istnieją:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('goal_challenges', 'goal_history');
```

Powinny zwrócić obie tabele.
