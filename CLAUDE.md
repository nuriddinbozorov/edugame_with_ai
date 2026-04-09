# EduGame — AI va Kengaytirilgan Gamifikatsiya Rejasi

## Loyiha haqida

**EduGame** — O'zbek tilida o'quvchilar (7-14 yosh) uchun gamifikatsiyalashgan ta'lim ilovasi.

- **Tech stack:** Flutter + Supabase (PostgreSQL) + Google Gemini free API
- **Til:** Barcha UI va AI javoblari O'zbek tilida (Lotin yozuvi)
- **AI model:** `gemini-1.5-flash` (bepul: 15 so'rov/daqiqa, 1M token/kun)

---

## Ilovani Ishga Tushirish

```bash
# Gemini API kalitini oling: https://aistudio.google.com/app/apikey
flutter run --dart-define=GEMINI_KEY=SIZNING_KALITINGIZ

# Kalit kiritilmasa AI o'chiq bo'ladi, ilova shunga qaramay ishlaydi
flutter run
```

---

## Amalga Oshirilgan Xususiyatlar

### Bosqich 1 — Asos (TAYYOR)
- `pubspec.yaml` — `google_generative_ai: ^0.4.3` qo'shildi
- `lib/services/rate_limiter.dart` — 15 RPM sliding window himoyasi
- `lib/services/gemini_service.dart` — Gemini singleton (savol generatori, EduBot, maslahat, tahlil)
- `lib/services/ai_provider.dart` — ChangeNotifier (chat holati boshqarish)
- `lib/models/ai_models.dart` — ChatMessage, PerformanceAnalysis, DailyChallenge, ShopItem

### Bosqich 2 — AI Xususiyatlari (TAYYOR)
- `lib/screens/quiz_screen.dart` — Maslahat tugmasi (har kvizda 2 bepul), DB bo'sh bo'lsa AI savollar
- `lib/screens/quiz_result_screen.dart` — AI tahlil kartochkasi (xulosa + tavsiyalar + motivatsiya)
- `lib/screens/ai_chat_screen.dart` — EduBot chat ekrani (4-chi tab)
- `lib/screens/home_screen.dart` — 4 tabli navigatsiya: Bosh | EduBot | Yetakchilar | Profil

---

## Keyingi Bosqichlar (Hali Bajarilmagan)

### Bosqich 3 — Kreativ Gamifikatsiya
- [ ] `lib/screens/daily_challenge_screen.dart` — Kunlik Vazifa kvizi
- [ ] `lib/screens/adventure_map_screen.dart` — Vizual Sarguzasht Xaritasi
- [ ] `lib/screens/shop_screen.dart` — Do'kon (tangalar/toshlar bilan)
- [ ] Navigatsiyani 5 tabga kengaytirish: Bosh | Xarita | EduBot | Reyting | Profil

### Bosqich 4 — Yaxshilashlar
- [ ] `home_screen.dart` — qattiq yozilgan fanlar (`'1'`, `'2'`) ni Supabase UUID lari bilan almashtirish
- [ ] Boss Fight rejimi (har 5 darajada qiyin savol)
- [ ] Kengaytirilgan Analytics ekrani (statik grafik o'rniga real data)
- [ ] `lib/services/daily_challenge_service.dart` — Kunlik vazifa logikasi

---

## Supabase — Yangi Jadvallar (SQL)

Supabase Dashboard > SQL Editor da ishga tushiring:

```sql
-- Kunlik vazifalar
CREATE TABLE IF NOT EXISTS daily_challenges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_date DATE NOT NULL UNIQUE,
  subject_id UUID REFERENCES subjects(id),
  title_uz TEXT NOT NULL,
  questions JSONB NOT NULL,
  reward_coins INTEGER DEFAULT 20,
  reward_gems INTEGER DEFAULT 5,
  reward_points INTEGER DEFAULT 50,
  is_ai_generated BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Foydalanuvchi kunlik vazifa natijalari
CREATE TABLE IF NOT EXISTS user_daily_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES daily_challenges(id),
  score INTEGER NOT NULL,
  completed_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, challenge_id)
);

-- AI suhbat tarixi (EduBot)
CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  subject_id UUID REFERENCES subjects(id),
  role TEXT NOT NULL CHECK (role IN ('user', 'model')),
  content TEXT NOT NULL,
  tokens_used INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Maslahat ishlatish jurnali
CREATE TABLE IF NOT EXISTS user_hints_used (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id),
  hint_text TEXT,
  gems_spent INTEGER DEFAULT 0,
  used_at TIMESTAMP DEFAULT NOW()
);

-- Do'kon mahsulotlari
CREATE TABLE IF NOT EXISTS shop_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_uz TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL CHECK (type IN ('avatar', 'theme', 'hint_pack', 'boost')),
  price_coins INTEGER DEFAULT 0,
  price_gems INTEGER DEFAULT 0,
  value JSONB,
  is_active BOOLEAN DEFAULT TRUE
);

-- Foydalanuvchi xaridlari
CREATE TABLE IF NOT EXISTS user_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES shop_items(id),
  price_coins_paid INTEGER DEFAULT 0,
  price_gems_paid INTEGER DEFAULT 0,
  purchased_at TIMESTAMP DEFAULT NOW()
);

-- RLS (Row Level Security)
ALTER TABLE daily_challenges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view daily challenges" ON daily_challenges FOR SELECT USING (true);

ALTER TABLE user_daily_completions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own completions" ON user_daily_completions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own completions" ON user_daily_completions FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own conversations" ON ai_conversations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own messages" ON ai_conversations FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE user_hints_used ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own hints" ON user_hints_used FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own hints" ON user_hints_used FOR INSERT WITH CHECK (auth.uid() = user_id);

ALTER TABLE shop_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Everyone can view shop items" ON shop_items FOR SELECT USING (true);

ALTER TABLE user_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own purchases" ON user_purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own purchases" ON user_purchases FOR INSERT WITH CHECK (auth.uid() = user_id);
```

---

## Gemini API Arxitekturasi

### GeminiService metodlari
```dart
// lib/services/gemini_service.dart
GeminiService().initialize(apiKey);           // main.dart da bir marta
GeminiService().generateQuestions(...)        // AI savollar
GeminiService().getChatResponse(...)          // EduBot chat
GeminiService().getHint(...)                  // Kviz maslahat
GeminiService().analyzePerformance(...)       // Test tahlili
```

### Rate Limiter
```dart
// lib/services/rate_limiter.dart
// 15 RPM sliding window — Gemini bepul tierini himoya qiladi
// Har API chaqiruvidan oldin avtomatik throttle qiladi
```

---

## AI Promptlari (O'zbek tilida)

### Savol Generatori
```
Sen "EduGame" ilovasining savol generatoriSan.
Fan: {subjectUz} | Daraja: {level}/10 | Savol soni: {count}

Qoidalar:
- Barcha savollar O'ZBEK tilida (Lotin yozuvi)
- Ko'p tanlovli: 4 variant, 1 ta to'g'ri
- Qiyinlik darajasi: {level} ga mos
- JSON formatida qaytargin, boshqa narsa yozma

Format:
{"questions":[{"question_text":"...","options":["A","B","C","D"],"correct_answer":"...","explanation_uz":"...","difficulty":"easy|medium|hard","points":10}]}
```

### EduBot Tizim Prompti
```
Sen "EduBot" — O'zbek maktab o'quvchilari (7-14 yosh) uchun AI o'qituvchiSan.
- Faqat O'ZBEK tilida (Lotin yozuvi) javob ber
- Qisqa, aniq, rag'batlantiruvchi bo'l (3-5 jumla)
- Faqat ta'lim mavzularida gapir
- Test javoblarini to'g'ridan-to'g'ri berma — yo'naltir
- Kirill yozuvidan foydalanma
```

### Natija Tahlili
```
O'quvchi: {name}, {grade}-sinf
Oxirgi testlar: {resultsJson}

JSON qaytargin:
{"xulosa":"...","kuchli_tomonlar":["..."],"zaif_tomonlar":["..."],"tavsiyalar":["...","...","..."],"motivatsiya":"...","maqsad":"..."}
```

### Maslahat (Hint)
```
Savol: {questionText}
Variantlar: {options}
Fan: {subjectUz}

Qoidalar: To'g'ri javobni AYTMA. Faqat 1-2 jumlada yo'naltir. O'ZBEK tilida yoz.
```

---

## Fayl Tuzilmasi (Muhim Fayllar)

```
lib/
  constants/
    app_constants.dart          — Ranglar, o'lchamlar, barcha UI matnlar
  models/
    user_model.dart             — User, UserStats
    subject_model.dart          — Subject, Question, TestResult, Achievement
    ai_models.dart              — ChatMessage, PerformanceAnalysis, DailyChallenge, ShopItem
  services/
    supabase_service.dart       — Barcha DB operatsiyalar (singleton)
    auth_provider.dart          — Auth holati (ChangeNotifier)
    gemini_service.dart         — Gemini AI (singleton)
    rate_limiter.dart           — 15 RPM himoyasi
    ai_provider.dart            — AI holati (ChangeNotifier)
  screens/
    login_screen.dart
    register_screen.dart
    forgot_password_screen.dart
    home_screen.dart            — 4 tab navigatsiya
    subject_screen.dart         — Fan daraja tanlash
    quiz_screen.dart            — Kviz (maslahat tugmasi bilan)
    quiz_result_screen.dart     — Natija (AI tahlil bilan)
    leaderboard_screen.dart
    profile_screen.dart
    ai_chat_screen.dart         — EduBot chat (YANGI)
  main.dart                     — App entry, MultiProvider
```

---

## Texnik Eslatmalar

1. **HomeScreen qattiq fanlar** — hozir `id: '1'`, `'2'`... real Supabase UUID emas. Kelajakda `getSubjects()` bilan almashtirish kerak.
2. **JSON parsing** — Gemini ba'zan markdown wrapper qo'shadi. `_extractJson()` helper avtomatik tozalaydi.
3. **Kviz taymer** — Maslahat bottom sheet ochilganda taymer to'xtaydi, yopilganda qayta ishga tushadi.
4. **Uzbek sifati** — Kirill belgilari kelsa, promptga `"Lotin yozuvida yoz"` qo'shish.
5. **Gemini kalit** — Hech qachon git ga push qilmang. `--dart-define` orqali kiriting.

---

## Navigatsiya Oqimi

```
RootScreen
├── LoginScreen → RegisterScreen
│                    └→ HomeScreen
└─→ HomeScreen (4 tab)
    ├── [0] Bosh sahifa → SubjectScreen → QuizScreen → QuizResultScreen
    ├── [1] EduBot → AiChatScreen
    ├── [2] Yetakchilar → LeaderboardScreen
    └── [3] Profil → ProfileScreen
```

---

## Test Qilish Tartibi

1. `flutter pub get`
2. `flutter run --dart-define=GEMINI_KEY=YOUR_KEY`
3. Login yoki ro'yxatdan o'ting
4. Fan tanlang → Daraja → Kviz
5. Kviz davomida lampa ikonka (maslahat) bosing → AI maslahat keladi
6. Kviz tugagach natija ekranida AI tahlilni ko'ring
7. Pastki navigatsiyada EduBot tab → savol yozing
