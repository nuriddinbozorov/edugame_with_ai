-- ============================================================
-- EDUGAME – Supabase qo'shimcha so'rovlar
-- Bu faylni Supabase Dashboard > SQL Editor da bajarishingiz kerak.
-- ============================================================

-- 1) USERS jadvaliga INSERT ruxsati (RLS)
-- Faqat supabase_full_setup.sql ishlatilmagan bo'lsa ishlatilsin.
-- supabase_full_setup.sql allaqachon ishlatilgan bo'lsa bu qism xato beradi –
-- o'sha paytda quyidagi satrni izohlang yoki supabase_fix_rls.sql dan foydalaning.
DROP POLICY IF EXISTS "Users can insert own row" ON users;
CREATE POLICY "Users can insert own row"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- 2) get_user_stats – foydalanuvchi statistikasi (ilova get_user_stats RPC ni chaqiradi)
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

-- 3) check_and_award_achievements – ball bo'yicha yutuqlarni tekshirish va berish
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
