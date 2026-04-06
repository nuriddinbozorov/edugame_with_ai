-- ============================================================
-- EDUGAME – Supabase to'liq sozlamalar (bitta fayl)
-- Supabase Dashboard > SQL Editor > New query > shu kodni yopishtiring > Run
-- ============================================================

-- ---------- USERS TABLE ----------
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  grade INTEGER,
  level INTEGER DEFAULT 1 CHECK (level > 0),
  points INTEGER DEFAULT 0 CHECK (points >= 0),
  coins INTEGER DEFAULT 0 CHECK (coins >= 0),
  gems INTEGER DEFAULT 0 CHECK (gems >= 0),
  streak INTEGER DEFAULT 0 CHECK (streak >= 0),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_points ON users(points DESC);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view all users"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own row"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ---------- SUBJECTS TABLE ----------
CREATE TABLE IF NOT EXISTS subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_uz TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  icon_path TEXT,
  color TEXT,
  total_levels INTEGER DEFAULT 10 CHECK (total_levels > 0),
  description TEXT,
  description_uz TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subjects_name_uz ON subjects(name_uz);

ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view subjects"
  ON subjects FOR SELECT
  USING (true);

-- ---------- QUESTIONS TABLE ----------
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  level INTEGER NOT NULL CHECK (level > 0),
  type TEXT NOT NULL,
  question_text TEXT NOT NULL,
  options TEXT[] NOT NULL CHECK (array_length(options, 1) >= 2),
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  explanation_uz TEXT,
  difficulty TEXT,
  points INTEGER DEFAULT 10 CHECK (points > 0),
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_questions_subject_level
  ON questions(subject_id, level);

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view questions"
  ON questions FOR SELECT
  USING (true);

-- ---------- TEST RESULTS TABLE ----------
CREATE TABLE IF NOT EXISTS test_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  level INTEGER NOT NULL CHECK (level > 0),
  score INTEGER NOT NULL CHECK (score >= 0),
  total_questions INTEGER NOT NULL CHECK (total_questions > 0),
  correct_answers INTEGER NOT NULL CHECK (correct_answers >= 0),
  answers JSONB,
  completed_at TIMESTAMP DEFAULT NOW(),
  duration_seconds INTEGER
);

CREATE INDEX IF NOT EXISTS idx_test_results_user_date
  ON test_results(user_id, completed_at DESC);

ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own results"
  ON test_results FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own results"
  ON test_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ---------- ACHIEVEMENTS TABLE ----------
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  name_uz TEXT NOT NULL UNIQUE,
  description TEXT,
  description_uz TEXT,
  icon_path TEXT,
  required_points INTEGER NOT NULL CHECK (required_points > 0),
  coins INTEGER DEFAULT 0 CHECK (coins >= 0),
  gems INTEGER DEFAULT 0 CHECK (gems >= 0),
  category TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Everyone can view achievements"
  ON achievements FOR SELECT
  USING (true);

-- ---------- USER ACHIEVEMENTS TABLE ----------
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user
  ON user_achievements(user_id);

ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view achievements"
  ON user_achievements FOR SELECT
  USING (true);

CREATE POLICY "System can insert achievements"
  ON user_achievements FOR INSERT
  WITH CHECK (true);

-- ---------- FUNCTIONS (RPC) ----------
CREATE OR REPLACE FUNCTION get_user_stats(user_id_param UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  result JSON;
  total_pts INTEGER;
  total_tests INTEGER;
  avg_sc DOUBLE PRECISION;
  total_ach INTEGER;
  cur_streak INTEGER;
BEGIN
  SELECT COALESCE(points, 0) INTO total_pts FROM users WHERE id = user_id_param;
  SELECT COALESCE(streak, 0) INTO cur_streak FROM users WHERE id = user_id_param;

  SELECT COUNT(*), COALESCE(AVG(100.0 * correct_answers / NULLIF(total_questions, 0)), 0)
  INTO total_tests, avg_sc
  FROM test_results
  WHERE user_id = user_id_param;

  SELECT COUNT(*) INTO total_ach
  FROM user_achievements
  WHERE user_id = user_id_param;

  result := json_build_object(
    'total_points', COALESCE(total_pts, 0),
    'total_tests', COALESCE(total_tests, 0),
    'avg_score', COALESCE(avg_sc, 0),
    'total_achievements', COALESCE(total_ach, 0),
    'current_streak', COALESCE(cur_streak, 0)
  );
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION check_and_award_achievements(user_id_param UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_pts INTEGER;
  ach RECORD;
  new_coins INTEGER := 0;
  new_gems INTEGER := 0;
BEGIN
  SELECT COALESCE(points, 0) INTO user_pts FROM users WHERE id = user_id_param;

  FOR ach IN
    SELECT id, coins, gems
    FROM achievements
    WHERE required_points <= user_pts
    AND id NOT IN (
      SELECT achievement_id FROM user_achievements WHERE user_id = user_id_param
    )
  LOOP
    INSERT INTO user_achievements (user_id, achievement_id)
    VALUES (user_id_param, ach.id)
    ON CONFLICT (user_id, achievement_id) DO NOTHING;

    new_coins := new_coins + COALESCE(ach.coins, 0);
    new_gems := new_gems + COALESCE(ach.gems, 0);
  END LOOP;

  IF new_coins > 0 OR new_gems > 0 THEN
    UPDATE users
    SET
      coins = COALESCE(coins, 0) + new_coins,
      gems = COALESCE(gems, 0) + new_gems,
      updated_at = NOW()
    WHERE id = user_id_param;
  END IF;
END;
$$;

-- ---------- TEST DATA ----------
INSERT INTO subjects (name, name_uz, type, color, total_levels) VALUES
  ('Mathematics', 'Matematika', 'mathematics', '4285F4', 10),
  ('Uzbek Language', 'O''zbek tili', 'uzbekLanguage', 'EA4335', 10),
  ('English', 'Ingliz tili', 'english', 'FBBC04', 10),
  ('Science', 'Tabiatshunoslik', 'science', '34A853', 10),
  ('History', 'Tarix', 'history', '9C27B0', 10),
  ('Geography', 'Geografiya', 'geography', '00ACC1', 10)
ON CONFLICT (name_uz) DO NOTHING;

INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, points)
SELECT id, 1, 'multipleChoice', '2 + 2 = ?', ARRAY['3', '4', '5', '6'], '4', 10
FROM subjects WHERE name_uz = 'Matematika'
UNION ALL
SELECT id, 1, 'multipleChoice', '5 × 3 = ?', ARRAY['12', '15', '18', '20'], '15', 10
FROM subjects WHERE name_uz = 'Matematika';

INSERT INTO achievements (name, name_uz, required_points, coins, gems) VALUES
  ('First Steps', 'Birinchi qadamlar', 10, 5, 0),
  ('Quiz Master', 'Quiz ustamalari', 100, 20, 5),
  ('Genius', 'Iqtidor', 500, 100, 50),
  ('Legendary', 'Afsonaviy', 1000, 500, 200)
ON CONFLICT (name) DO NOTHING;
