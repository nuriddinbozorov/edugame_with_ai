-- ============================================================
-- EDUGAME – Barcha fanlar uchun savollar (Seed)
-- Supabase Dashboard > SQL Editor > Run
-- ============================================================

-- Ustunlar mavjud bo'lmasa qo'shib olamiz
ALTER TABLE questions ADD COLUMN IF NOT EXISTS explanation_uz TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS difficulty TEXT;


-- ==================== MATEMATIKA ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, '2 + 2 = ?', ARRAY['3','4','5','6'], '4', 'Ikki va ikkini qo''shsak to''rtta chiqadi.', 'easy', 10),
  (1, '5 × 3 = ?', ARRAY['12','15','18','20'], '15', 'Beshni uchga ko''paytirsak: 5+5+5=15.', 'easy', 10),
  (1, '10 - 7 = ?', ARRAY['2','3','4','5'], '3', 'O''ndan yettini ayirsak uchta qoladi.', 'easy', 10),
  (1, '20 ÷ 4 = ?', ARRAY['4','5','6','7'], '5', 'Yigirmani to''rtga bo''lsak beshta chiqadi.', 'easy', 10),
  (1, '3 × 7 = ?', ARRAY['18','21','24','27'], '21', 'Uchni yettiga ko''paytirsak: 3×7=21.', 'easy', 10),
  (1, '15 + 8 = ?', ARRAY['21','22','23','24'], '23', 'O''n besh va sakkizni qo''shsak yigirma uch chiqadi.', 'easy', 10),
  (1, '9 × 9 = ?', ARRAY['72','81','90','99'], '81', 'Toʻqqizni toʻqqizga koʻpaytirish: 81.', 'easy', 10),
  (1, '36 ÷ 6 = ?', ARRAY['5','6','7','8'], '6', 'Otuz oltini oltiga bo''lsak olti chiqadi.', 'easy', 10),
  -- Level 2
  (2, '25 + 37 = ?', ARRAY['52','62','72','82'], '62', 'Yigirma besh va o''ttiz yettini qo''shsak: 62.', 'easy', 20),
  (2, '100 - 43 = ?', ARRAY['47','53','57','67'], '57', 'Yuzdan qirq uchni ayirsak: 57.', 'easy', 20),
  (2, '12 × 5 = ?', ARRAY['50','55','60','65'], '60', 'O''n ikkini beshga ko''paytirsak: 60.', 'easy', 20),
  (2, '144 ÷ 12 = ?', ARRAY['10','11','12','13'], '12', 'Yuz qirq to''rtni o''n ikkiga bo''lsak: 12.', 'medium', 20),
  (2, 'Eng kichik tub son qaysi?', ARRAY['0','1','2','3'], '2', '2 — eng kichik tub son.', 'medium', 20),
  -- Level 3
  (3, '125 + 375 = ?', ARRAY['400','450','500','550'], '500', 'Yuz yigirma besh va uch yuz yetmish besh: 500.', 'medium', 30),
  (3, '7² = ?', ARRAY['14','42','49','56'], '49', 'Yettining kvadrati: 7×7=49.', 'medium', 30),
  (3, 'Uchburchak burchaklari yig''indisi = ?', ARRAY['90°','120°','180°','360°'], '180°', 'Har qanday uchburchak burchaklari yig''indisi 180° ga teng.', 'medium', 30),
  (3, '√64 = ?', ARRAY['6','7','8','9'], '8', 'Saksonning kvadrat ildizi sakkizga teng.', 'medium', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'Matematika'
ON CONFLICT DO NOTHING;

-- ==================== O'ZBEK TILI ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, '"Kitob" so''zining ko''pligi qanday?', ARRAY['Kitoblar','Kitoblon','Kitobliklar','Kitobcha'], 'Kitoblar', 'Ko''plik -lar qo''shimchasi bilan yasaladi.', 'easy', 10),
  (1, 'Qaysi so''z ot turkumiga kiradi?', ARRAY['Yugurmoq','Baland','Daryo','Tez'], 'Daryo', 'Daryo — narsa-hodisa nomini bildiradi, ya''ni ot.', 'easy', 10),
  (1, '"Men maktabga boraman" — bu gapda ega qaysi?', ARRAY['maktabga','boraman','Men','bo''lmaydi'], 'Men', 'Ega — gapda kim? nima? savollariga javob beruvchi so''z.', 'easy', 10),
  (1, 'Qaysi so''z sifat?', ARRAY['O''qimoq','Ko''k','Daryo','Sekin'], 'Ko''k', 'Ko''k — rangni bildiradi, ya''ni sifat.', 'easy', 10),
  (1, '"Do''st" so''ziga qarama-qarshi ma''no?', ARRAY['Aka','Dushman','Qo''shni','Tanish'], 'Dushman', 'Do''stning antonimi — dushman.', 'easy', 10),
  (1, 'Qaysi so''z fe''l?', ARRAY['Baland','Tosh','O''qimoq','Katta'], 'O''qimoq', 'Fe''l — harakat bildiradi.', 'easy', 10),
  (1, '"Quyosh" so''zida nechta harf bor?', ARRAY['5','6','7','8'], '6', 'Q-u-y-o-s-h — 6 ta harf.', 'easy', 10),
  (1, 'O''zbek alifbosida nechta harf bor?', ARRAY['26','29','30','32'], '29', 'O''zbek lotin alifbosida 29 ta harf mavjud.', 'easy', 10),
  -- Level 2
  (2, '"Chiroyli" so''zining so''roq shakli?', ARRAY['Chiroylilar','Chiroy','Chiroylik','Chiroylidir'], 'Chiroylidir', '-dir qo''shimchasi kesimlik bildiradi.', 'medium', 20),
  (2, 'Qaysi qatorda imlo xatosi bor?', ARRAY['Toshkent','O''zbekiston','Samarqand','Buxoro'], 'O''zbekiston', 'To''g''ri yozilishi: O''zbekiston.', 'medium', 20),
  (2, 'Murakkab gap nima?', ARRAY['Bir kesimli gap','Ikki va undan ko''p kesimli gap','Buyruq gap','So''roq gap'], 'Ikki va undan ko''p kesimli gap', 'Murakkab gapda ikki yoki undan ortiq kesim bo''ladi.', 'medium', 20),
  (2, '"Kitob o''qimoq" iborasida "o''qimoq" so''zi nima?', ARRAY['Ot','Sifat','Fe''l','Ravish'], 'Fe''l', 'O''qimoq harakat bildiradi — fe''l.', 'easy', 20),
  -- Level 3
  (3, 'Paronimlar nima?', ARRAY['Bir xil ma''noli so''zlar','Talaffuzi o''xshash, ma''nosi boshqa so''zlar','Qarama-qarshi ma''noli so''zlar','Ko''p ma''noli so''zlar'], 'Talaffuzi o''xshash, ma''nosi boshqa so''zlar', 'Paronimlar — talaffuzi yaqin, ammo ma''nosi farqli so''zlar.', 'hard', 30),
  (3, '"Sariq" so''zi qaysi sinonimga ega?', ARRAY['Ko''k','Sarg''ish','Qizil','Oq'], 'Sarg''ish', 'Sariq va sarg''ish — sinonim so''zlar.', 'medium', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'O''zbek tili'
ON CONFLICT DO NOTHING;

-- ==================== INGLIZ TILI ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, '"Apple" o''zbekcha nimani anglatadi?', ARRAY['Olma','Nok','Uzum','Shaftoli'], 'Olma', 'Apple — olma degan ma''noni bildiradi.', 'easy', 10),
  (1, '"I ___ a student." Bo''sh joyga nima?', ARRAY['is','am','are','be'], 'am', 'I bilan am ishlatiladi.', 'easy', 10),
  (1, '"Red" o''zbekcha?', ARRAY['Ko''k','Yashil','Qizil','Sariq'], 'Qizil', 'Red — qizil rang.', 'easy', 10),
  (1, '"Dog" ko''pligi qanday?', ARRAY['Dogies','Dogs','Doges','Dogses'], 'Dogs', 'Ko''plikda -s qo''shimchasi qo''shiladi.', 'easy', 10),
  (1, '"Good morning" nimani anglatadi?', ARRAY['Xayr','Assalomu alaykum','Hayrli tong','Rahmat'], 'Hayrli tong', 'Good morning — hayrli tong degan ma''no.', 'easy', 10),
  (1, '"She ___ going to school." To''ldiring:', ARRAY['am','is','are','be'], 'is', 'She uchun is ishlatiladi.', 'easy', 10),
  (1, 'Inglizcha 1-10 sanashda 7 nima?', ARRAY['Six','Seven','Eight','Nine'], 'Seven', 'Seven — yetti.', 'easy', 10),
  (1, '"Book" o''zbek tilida?', ARRAY['Ruchka','Daftar','Kitob','Qalam'], 'Kitob', 'Book — kitob.', 'easy', 10),
  -- Level 2
  (2, '"He ___ football every day." To''ldiring:', ARRAY['play','plays','playing','played'], 'plays', 'He, she, it bilan fe''lga -s/-es qo''shiladi.', 'easy', 20),
  (2, '"Yesterday" qaysi zamon uchun?', ARRAY['Present','Future','Past','All'], 'Past', 'Yesterday — o''tgan zamon belgisi.', 'easy', 20),
  (2, '"Beautiful" so''zining ma''nosi?', ARRAY['Kuchli','Chiroyli','Tez','Katta'], 'Chiroyli', 'Beautiful — chiroyli, go''zal.', 'easy', 20),
  (2, 'Qaysi so''z olmosh (pronoun)?', ARRAY['Run','Happy','They','School'], 'They', 'They — ular (olmosh).', 'medium', 20),
  -- Level 3
  (3, '"I have been studying for 2 hours." Bu qaysi zamon?', ARRAY['Past Simple','Present Perfect','Present Perfect Continuous','Past Continuous'], 'Present Perfect Continuous', 'Have been + V-ing — Present Perfect Continuous.', 'hard', 30),
  (3, '"Antonym" of "ancient"?', ARRAY['Old','Modern','Big','Slow'], 'Modern', 'Ancient — qadimiy, modern — zamonaviy (antonim).', 'medium', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'Ingliz tili'
ON CONFLICT DO NOTHING;

-- ==================== TABIATSHUNOSLIK ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, 'Quyosh qaysi sayyoramizga eng yaqin yulduz?', ARRAY['Mars','Oy','Quyosh','Venera'], 'Quyosh', 'Quyosh — Yerga eng yaqin yulduz.', 'easy', 10),
  (1, 'Suvning kimyoviy formulasi?', ARRAY['CO2','H2O','O2','NaCl'], 'H2O', 'Suv — ikkita vodorod va bitta kislorod atomidan iborat.', 'easy', 10),
  (1, 'O''simliklar fotosintez uchun nimadan foydalanadi?', ARRAY['Kislorod','Azot','Karbonat angidrid','Vodorod'], 'Karbonat angidrid', 'O''simliklar CO2 va quyosh nuri orqali fotosintez qiladi.', 'easy', 10),
  (1, 'Odamda nechta oldingi tish bor?', ARRAY['2','4','6','8'], '8', 'Odamda 4 ta kesuvchi va 4 ta qoziq tish (krak), 8 ta oldingi tish.', 'easy', 10),
  (1, 'Eng katta hayvon qaysi?', ARRAY['Fil','Ko''k kit','Zubr','Timsoh'], 'Ko''k kit', 'Ko''k kit — Yer yuzidagi eng katta hayvon.', 'easy', 10),
  (1, 'Qaysi gazni nafas olamiz?', ARRAY['Azot','Kislorod','Vodorod','CO2'], 'Kislorod', 'Nafas olishda kislorod ishlatilib, CO2 chiqariladi.', 'easy', 10),
  (1, 'Quyosh sistemasida nechta sayyora bor?', ARRAY['7','8','9','10'], '8', '2006-yildan Pluton sayyoralar ro''yxatidan chiqarildi, 8 ta sayyora qoldi.', 'easy', 10),
  -- Level 2
  (2, 'Qon guruhlarining turlari nechta?', ARRAY['2','3','4','5'], '4', 'Qon guruhlari: I, II, III, IV — jami 4 ta.', 'easy', 20),
  (2, 'Yorug''lik 1 soniyada qancha masofani bosib o''tadi?', ARRAY['100 000 km','200 000 km','300 000 km','400 000 km'], '300 000 km', 'Yorug''lik tezligi — 300 000 km/s.', 'medium', 20),
  (2, 'Fotosintez jarayonida qanday gaz ajraladi?', ARRAY['CO2','Azot','Kislorod','Vodorod'], 'Kislorod', 'Fotosintezda kislorod ajralib chiqadi.', 'easy', 20),
  (2, 'Insonning normal harorati necha daraja?', ARRAY['35°C','36,6°C','37,5°C','38°C'], '36,6°C', 'Odamning normal tana harorati 36,6°C.', 'easy', 20),
  -- Level 3
  (3, 'DNA nima?', ARRAY['Oqsil','Dezoksiribonuklein kislota','Yog''','Uglerod'], 'Dezoksiribonuklein kislota', 'DNA — irsiy ma''lumot saqlovchi dezoksiribonuklein kislota.', 'medium', 30),
  (3, 'Qaysi vitaminni quyosh nuri orqali hosil qiladi?', ARRAY['A vitamini','B vitamini','C vitamini','D vitamini'], 'D vitamini', 'D vitamini quyosh nurlari ta''sirida terida hosil bo''ladi.', 'medium', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'Tabiatshunoslik'
ON CONFLICT DO NOTHING;

-- ==================== TARIX ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, 'O''zbekiston mustaqilligini qaysi yilda qo''lga kiritdi?', ARRAY['1989','1990','1991','1992'], '1991', 'O''zbekiston 1991-yil 1-sentabrda mustaqillikni e''lon qildi.', 'easy', 10),
  (1, 'Amir Temur qaysi shaharni poytaxt qilgan?', ARRAY['Buxoro','Xiva','Samarqand','Toshkent'], 'Samarqand', 'Amir Temur Samarqandni o''z imperiyasining poytaxti qildi.', 'easy', 10),
  (1, 'Birinchi jahon urushi qaysi yillarda bo''lgan?', ARRAY['1904-1907','1914-1918','1918-1922','1939-1945'], '1914-1918', 'Birinchi jahon urushi 1914-1918-yillarda bo''ldi.', 'easy', 10),
  (1, 'Al-Xorazmiy qaysi sohada mashhur?', ARRAY['Tibbiyot','Matematika va astronomiya','San''at','Adabiyot'], 'Matematika va astronomiya', 'Al-Xorazmiy algebra va algoritm fanlarining asoschilaridan biri.', 'easy', 10),
  (1, 'Buyuk Ipak Yo''li qaysi mamlakatlarni bog''lagan?', ARRAY['Faqat Xitoy va Rim','Xitoy va G''arb mamlakatlari','Faqat Osiyo','Faqat Yevropa'], 'Xitoy va G''arb mamlakatlari', 'Ipak Yo''li Xitoydan Yevropa va G''arb mamlakatlariga cho''zilgan.', 'easy', 10),
  (1, 'Toshkent O''zbekistonning poytaxti bo''lganidan buyon necha yil bo''ldi (2024)?', ARRAY['Har doim poytaxt','1930-yillardan','1991-yildan','2000-yildan'], '1930-yillardan', 'Toshkent 1930-yillarda Sovet O''zbekistonining poytaxti bo''ldi.', 'medium', 10),
  -- Level 2
  (2, 'Ikkinchi jahon urushi qachon tugadi?', ARRAY['1943','1944','1945','1946'], '1945', 'Ikkinchi jahon urushi 1945-yil 9-mayda (Yevropa) va 2-sentabrda (Osiyoda) tugadi.', 'easy', 20),
  (2, 'Ibn Sino qaysi soha mutaxassisi?', ARRAY['Riyoziyot','Tarix','Tibbiyot va falsafa','Astronomiya'], 'Tibbiyot va falsafa', 'Ibn Sino (Avitsenna) — buyuk tabib va faylasuf.', 'easy', 20),
  (2, 'O''zbekiston Respublikasining birinchi Prezidenti kim?', ARRAY['Sh.Mirziyoyev','I.Karimov','R.Inomov','A.Jalolov'], 'I.Karimov', 'Islom Karimov O''zbekistonning birinchi Prezidenti bo''lgan.', 'easy', 20),
  -- Level 3
  (3, 'Temuriylar davlati qachon yemirildi?', ARRAY['1400','1450','1500','1507'], '1507', 'Shayboniyxon 1507-yilda Temuriylar davlatini tugатди.', 'hard', 30),
  (3, 'Qaysi olim "Qonun fi-t-tib" asarini yozgan?', ARRAY['Al-Xorazmiy','Al-Beruniy','Ibn Sino','Mirzo Ulug''bek'], 'Ibn Sino', '"Qonun fi-t-tibb" — Ibn Sinoning eng mashhur tibbiy asari.', 'medium', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'Tarix'
ON CONFLICT DO NOTHING;

-- ==================== GEOGRAFIYA ====================
INSERT INTO questions (subject_id, level, type, question_text, options, correct_answer, explanation_uz, difficulty, points)
SELECT s.id, q.level, 'multipleChoice', q.question_text, q.options, q.correct_answer, q.explanation_uz, q.difficulty, q.points
FROM subjects s
CROSS JOIN (VALUES
  -- Level 1
  (1, 'Dunyodagi eng uzun daryo qaysi?', ARRAY['Amazon','Nil','Volga','Yanszı'], 'Nil', 'Nil daryosi — dunyodagi eng uzun daryo (6650 km).', 'easy', 10),
  (1, 'O''zbekiston qaysi qit''ada joylashgan?', ARRAY['Afrika','Yevropa','Osiyo','Amerika'], 'Osiyo', 'O''zbekiston Markaziy Osiyoda joylashgan.', 'easy', 10),
  (1, 'Dunyodagi eng katta okean qaysi?', ARRAY['Atlantika','Hind','Shimoliy Muz','Tinch'], 'Tinch', 'Tinch (Pasifik) okeani — dunyodagi eng katta okean.', 'easy', 10),
  (1, 'O''zbekiston nechta viloyatdan iborat?', ARRAY['10','12','14','15'], '14', 'O''zbekiston 14 viloyat va 1 Qoraqalpog''iston Respublikasidan iborat.', 'easy', 10),
  (1, 'Qaysi tog'' tizimi Osiyo va Yevropani ajratib turadi?', ARRAY['Alplar','Himolay','Ural','Kavkaz'], 'Ural', 'Ural tog'' tizimi Osiyo va Yevropaning chegarasi hisoblanadi.', 'easy', 10),
  (1, 'Dunyo qit''alari soni nechta?', ARRAY['5','6','7','8'], '7', 'Yer yuzida 7 ta qit''a mavjud.', 'easy', 10),
  (1, 'Orol dengizining joylashuvi?', ARRAY['Qozoniston va Turkmaniston','O''zbekiston va Qozog''iston','Tojikiston va Qirg''iziston','Turkmaniston va Afg''oniston'], 'O''zbekiston va Qozog''iston', 'Orol dengizi O''zbekiston va Qozog''iston chegarasida joylashgan.', 'easy', 10),
  -- Level 2
  (2, 'Dunyodagi eng baland tog'' qaysi?', ARRAY['K2','Cho''Oyu','Everest','Lotshe'], 'Everest', 'Everest (8849 m) — dunyodagi eng baland cho''qqi.', 'easy', 20),
  (2, 'O''zbekistonning qaysi shahri "Sharqning Pariji" deb ataladi?', ARRAY['Toshkent','Buxoro','Xiva','Samarqand'], 'Samarqand', 'Samarqand o''z me''morchiligi va tarixi bilan mashhur.', 'easy', 20),
  (2, 'Kaspiy dengizi aslida nima?', ARRAY['Dengiz','Ko''l','Daryo','Okean'], 'Ko''l', 'Kaspiy — dunyodagi eng katta ko''l (dengiz deb ataladi lekin ko''l).', 'medium', 20),
  (2, 'Nil daryosi qaysi qit''ada joylashgan?', ARRAY['Osiyo','Yevropa','Afrika','Amerika'], 'Afrika', 'Nil daryosi Afrika qit''asida joylashgan.', 'easy', 20),
  -- Level 3
  (3, 'O''zbekistonning ikki tomoni dengizga chiqmaydigan qo''shni davlatlar bilan o''ralgan — bu qanday holat?', ARRAY['Arxipelag','Yarim orol','Ikki marta quruqlik o''ralgan','Orol'], 'Ikki marta quruqlik o''ralgan', 'O''zbekiston "double landlocked" — qo''shnilari ham dengizga chiqmaydi.', 'hard', 30),
  (3, 'Amazon daryosi qaysi qit''ada?', ARRAY['Afrika','Osiyo','Janubiy Amerika','Shimoliy Amerika'], 'Janubiy Amerika', 'Amazon daryosi Janubiy Amerikada joylashgan.', 'easy', 30)
) AS q(level, question_text, options, correct_answer, explanation_uz, difficulty, points)
WHERE s.name_uz = 'Geografiya'
ON CONFLICT DO NOTHING;
