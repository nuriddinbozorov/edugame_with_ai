-- ============================================================
-- EDUGAME – Trigger: auth.users ga yangi foydalanuvchi qo'shilganda
-- public.users jadvalini avtomatik to'ldiradi.
--
-- Supabase Dashboard > SQL Editor > New query > shu kodni ishga tushiring
-- ============================================================

-- Trigger funksiyasi
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, name, email, grade, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    NULLIF(NEW.raw_user_meta_data->>'grade', '')::INTEGER,
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Trigger: auth.users ga INSERT bo'lganda chaqiriladi
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
