-- ============================================================
-- EDUGAME – RLS Policy'larini tuzatish
-- Supabase Dashboard > SQL Editor > New query da buni jarayonlang
-- ============================================================

-- Eski policy'larni o'chirish
DROP POLICY IF EXISTS "Users can insert own row" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can view all users" ON users;

-- Yangi policy'lar qo'shish (AUTHENTICATED users uchun)
CREATE POLICY "Authenticated users can insert own row"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Authenticated users can view all users"
  ON users FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can update own data"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Anonymous users uchun (agar kerak bo'lsa)
CREATE POLICY "Anon users can view users"
  ON users FOR SELECT
  TO anon
  USING (true);

COMMIT;
