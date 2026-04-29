-- Voxera Vocabulary App - Full Schema Migration
-- Tables: words, word_progress, user_profiles
-- Features: Admin panel, category/level filtering, TTS support

-- ============================================================
-- 1. TYPES
-- ============================================================
DO $$ BEGIN
    CREATE TYPE public.word_difficulty AS ENUM ('A1', 'A2', 'B1', 'B2', 'C1', 'C2');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE public.word_status_type AS ENUM ('newWord', 'learning', 'known', 'weak');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- ============================================================
-- 2. CORE TABLES
-- ============================================================

-- User profiles (linked to auth.users via trigger)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL DEFAULT '',
    avatar_url TEXT DEFAULT '',
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Words table (managed by admin)
CREATE TABLE IF NOT EXISTS public.words (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    word TEXT NOT NULL,
    phonetic TEXT NOT NULL DEFAULT '',
    meaning TEXT NOT NULL,
    example TEXT NOT NULL DEFAULT '',
    category TEXT NOT NULL DEFAULT 'General',
    difficulty public.word_difficulty NOT NULL DEFAULT 'A1'::public.word_difficulty,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Add difficulty column if it doesn't exist (for idempotency)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'words'
          AND column_name = 'difficulty'
    ) THEN
        ALTER TABLE public.words
            ADD COLUMN difficulty public.word_difficulty NOT NULL DEFAULT 'A1'::public.word_difficulty;
    END IF;
END $$;

-- Word progress per user
CREATE TABLE IF NOT EXISTS public.word_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    word_id UUID NOT NULL REFERENCES public.words(id) ON DELETE CASCADE,
    status public.word_status_type DEFAULT 'newWord'::public.word_status_type,
    known_count INTEGER DEFAULT 0,
    unknown_count INTEGER DEFAULT 0,
    next_review_date TIMESTAMPTZ,
    last_reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, word_id)
);

-- ============================================================
-- 3. INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_words_difficulty ON public.words(difficulty);
CREATE INDEX IF NOT EXISTS idx_words_category ON public.words(category);
CREATE INDEX IF NOT EXISTS idx_word_progress_user_id ON public.word_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_word_progress_word_id ON public.word_progress(word_id);
CREATE INDEX IF NOT EXISTS idx_word_progress_status ON public.word_progress(status);
CREATE INDEX IF NOT EXISTS idx_word_progress_next_review ON public.word_progress(next_review_date);

-- ============================================================
-- 4. FUNCTIONS (BEFORE RLS POLICIES)
-- ============================================================

-- Auto-create user profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, avatar_url, is_admin)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', ''),
        CASE WHEN NEW.email = 'osmanemreyaygin0@gmail.com' THEN true ELSE false END
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        is_admin = CASE WHEN NEW.email = 'osmanemreyaygin0@gmail.com' THEN true ELSE false END;
    RETURN NEW;
END;
$$;

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Check if current user is admin (uses auth.users to avoid recursion)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE id = auth.uid() AND is_admin = true
)
$$;

-- ============================================================
-- 5. ENABLE RLS
-- ============================================================
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.words ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.word_progress ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- 6. RLS POLICIES
-- ============================================================

-- user_profiles: users manage own profile
DROP POLICY IF EXISTS "users_manage_own_user_profiles" ON public.user_profiles;
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- words: everyone can read, only admins can write
DROP POLICY IF EXISTS "anyone_can_read_words" ON public.words;
CREATE POLICY "anyone_can_read_words"
ON public.words
FOR SELECT
TO authenticated
USING (true);

DROP POLICY IF EXISTS "admins_can_insert_words" ON public.words;
CREATE POLICY "admins_can_insert_words"
ON public.words
FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "admins_can_update_words" ON public.words;
CREATE POLICY "admins_can_update_words"
ON public.words
FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "admins_can_delete_words" ON public.words;
CREATE POLICY "admins_can_delete_words"
ON public.words
FOR DELETE
TO authenticated
USING (public.is_admin());

-- word_progress: users manage own progress
DROP POLICY IF EXISTS "users_manage_own_word_progress" ON public.word_progress;
CREATE POLICY "users_manage_own_word_progress"
ON public.word_progress
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ============================================================
-- 7. TRIGGERS
-- ============================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_words_updated_at ON public.words;
CREATE TRIGGER update_words_updated_at
    BEFORE UPDATE ON public.words
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_word_progress_updated_at ON public.word_progress;
CREATE TRIGGER update_word_progress_updated_at
    BEFORE UPDATE ON public.word_progress
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================
-- 8. SEED DATA - Sample vocabulary words
-- ============================================================
DO $$
BEGIN
    -- Insert sample words across all levels and categories
    INSERT INTO public.words (id, word, phonetic, meaning, example, category, difficulty) VALUES
        (gen_random_uuid(), 'apple', '/ˈæp.əl/', 'elma', 'I eat an apple every day.', 'Food', 'A1'::public.word_difficulty),
        (gen_random_uuid(), 'book', '/bʊk/', 'kitap', 'She is reading a book.', 'Education', 'A1'::public.word_difficulty),
        (gen_random_uuid(), 'house', '/haʊs/', 'ev', 'They live in a big house.', 'Home', 'A1'::public.word_difficulty),
        (gen_random_uuid(), 'water', '/ˈwɔː.tər/', 'su', 'Please give me some water.', 'Food', 'A1'::public.word_difficulty),
        (gen_random_uuid(), 'school', '/skuːl/', 'okul', 'The children go to school.', 'Education', 'A1'::public.word_difficulty),
        (gen_random_uuid(), 'travel', '/ˈtræv.əl/', 'seyahat etmek', 'I love to travel abroad.', 'Travel', 'A2'::public.word_difficulty),
        (gen_random_uuid(), 'market', '/ˈmɑː.kɪt/', 'pazar, market', 'We shop at the local market.', 'Shopping', 'A2'::public.word_difficulty),
        (gen_random_uuid(), 'weather', '/ˈweð.ər/', 'hava durumu', 'The weather is nice today.', 'Nature', 'A2'::public.word_difficulty),
        (gen_random_uuid(), 'friend', '/frend/', 'arkadaş', 'She is my best friend.', 'Social', 'A2'::public.word_difficulty),
        (gen_random_uuid(), 'computer', '/kəmˈpjuː.tər/', 'bilgisayar', 'I use a computer for work.', 'Technology', 'A2'::public.word_difficulty),
        (gen_random_uuid(), 'environment', '/ɪnˈvaɪ.rən.mənt/', 'çevre', 'We must protect the environment.', 'Nature', 'B1'::public.word_difficulty),
        (gen_random_uuid(), 'opportunity', '/ˌɒp.əˈtʃuː.nɪ.ti/', 'fırsat', 'This is a great opportunity.', 'Business', 'B1'::public.word_difficulty),
        (gen_random_uuid(), 'experience', '/ɪkˈspɪə.ri.əns/', 'deneyim', 'She has a lot of experience.', 'Work', 'B1'::public.word_difficulty),
        (gen_random_uuid(), 'government', '/ˈɡʌv.ən.mənt/', 'hükümet', 'The government passed a new law.', 'Politics', 'B1'::public.word_difficulty),
        (gen_random_uuid(), 'technology', '/tekˈnɒl.ə.dʒi/', 'teknoloji', 'Technology changes our lives.', 'Technology', 'B1'::public.word_difficulty),
        (gen_random_uuid(), 'sophisticated', '/səˈfɪs.tɪ.keɪ.tɪd/', 'sofistike, karmaşık', 'The system is very sophisticated.', 'Academic', 'B2'::public.word_difficulty),
        (gen_random_uuid(), 'consequence', '/ˈkɒn.sɪ.kwəns/', 'sonuç, etki', 'Consider the consequences of your actions.', 'Academic', 'B2'::public.word_difficulty),
        (gen_random_uuid(), 'perspective', '/pəˈspek.tɪv/', 'bakış açısı', 'Try to see it from a different perspective.', 'Academic', 'B2'::public.word_difficulty),
        (gen_random_uuid(), 'phenomenon', '/fɪˈnɒm.ɪ.nən/', 'fenomen, olgu', 'This is a natural phenomenon.', 'Science', 'C1'::public.word_difficulty),
        (gen_random_uuid(), 'ambiguous', '/æmˈbɪɡ.ju.əs/', 'belirsiz, muğlak', 'The instructions were ambiguous.', 'Academic', 'C1'::public.word_difficulty),
        (gen_random_uuid(), 'paradigm', '/ˈpær.ə.daɪm/', 'paradigma, örnek', 'This represents a paradigm shift.', 'Academic', 'C1'::public.word_difficulty),
        (gen_random_uuid(), 'ubiquitous', '/juːˈbɪk.wɪ.təs/', 'her yerde bulunan', 'Smartphones are ubiquitous today.', 'Technology', 'C2'::public.word_difficulty),
        (gen_random_uuid(), 'ephemeral', '/ɪˈfem.ər.əl/', 'geçici, kısa ömürlü', 'Fame can be ephemeral.', 'Literature', 'C2'::public.word_difficulty),
        (gen_random_uuid(), 'sycophant', '/ˈsɪk.ə.fənt/', 'dalkavuk', 'He surrounded himself with sycophants.', 'Social', 'C2'::public.word_difficulty)
    ON CONFLICT (id) DO NOTHING;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Seed data insertion failed: %', SQLERRM;
END $$;
