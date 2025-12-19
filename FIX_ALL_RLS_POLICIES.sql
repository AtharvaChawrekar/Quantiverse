-- ============================================================================
-- COMPREHENSIVE RLS POLICY FIX FOR ALL BUCKETS AND TABLES
-- Run this entire script in Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- STEP 1: FIX STORAGE BUCKET POLICIES
-- ============================================================================

-- ─────────────────────────────────────────────────────────────────────────
-- 1.1 TASK-MATERIALS BUCKET POLICIES
-- ─────────────────────────────────────────────────────────────────────────

-- Drop all existing task-materials policies
DROP POLICY IF EXISTS "Admins can upload task materials" ON storage.objects;
DROP POLICY IF EXISTS "Any authenticated user can upload task materials" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update task materials" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete task materials" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can view task materials" ON storage.objects;

-- Create new task-materials policies
CREATE POLICY "Public read task materials"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'task-materials');

CREATE POLICY "Authenticated upload task materials"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'task-materials');

CREATE POLICY "Authenticated update task materials"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'task-materials');

CREATE POLICY "Authenticated delete task materials"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'task-materials');

-- ─────────────────────────────────────────────────────────────────────────
-- 1.2 SUBMISSIONS BUCKET POLICIES
-- ─────────────────────────────────────────────────────────────────────────

-- Drop all existing submission policies
DROP POLICY IF EXISTS "Users can upload their own submissions" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own submissions" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own submissions" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own submissions" ON storage.objects;

-- Create new submissions policies - simpler approach
CREATE POLICY "Authenticated upload submissions"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'submissions');

CREATE POLICY "Authenticated read submissions"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'submissions');

CREATE POLICY "Authenticated update submissions"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'submissions');

CREATE POLICY "Authenticated delete submissions"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'submissions');

-- ─────────────────────────────────────────────────────────────────────────
-- 1.3 RESUMES BUCKET POLICIES
-- ─────────────────────────────────────────────────────────────────────────

-- Drop all existing resume policies
DROP POLICY IF EXISTS "Users can upload their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can view their own resumes" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own resumes" ON storage.objects;

-- Create new resume policies
CREATE POLICY "Authenticated upload resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'resumes');

CREATE POLICY "Authenticated read resumes"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'resumes');

CREATE POLICY "Authenticated update resumes"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'resumes');

CREATE POLICY "Authenticated delete resumes"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'resumes');

-- ============================================================================
-- STEP 2: FIX DATABASE TABLE RLS POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_task_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_readiness_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────────────────
-- 2.1 SIMULATIONS TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

-- Drop all existing simulations policies
DROP POLICY IF EXISTS "Allow public read simulations" ON simulations;
DROP POLICY IF EXISTS "Allow authenticated read simulations" ON simulations;
DROP POLICY IF EXISTS "Allow admin insert simulations" ON simulations;
DROP POLICY IF EXISTS "Allow admin update simulations" ON simulations;
DROP POLICY IF EXISTS "Allow admin delete simulations" ON simulations;

-- Create new simulations policies - allow all authenticated users to read
CREATE POLICY "Public read all simulations"
ON simulations FOR SELECT
USING (true);

-- Allow authenticated users to insert (for now, can restrict to admins later)
CREATE POLICY "Authenticated insert simulations"
ON simulations FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update
CREATE POLICY "Authenticated update simulations"
ON simulations FOR UPDATE
TO authenticated
USING (true);

-- Allow authenticated users to delete
CREATE POLICY "Authenticated delete simulations"
ON simulations FOR DELETE
TO authenticated
USING (true);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.2 TASKS TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Public read tasks" ON tasks;
DROP POLICY IF EXISTS "Authenticated insert tasks" ON tasks;
DROP POLICY IF EXISTS "Authenticated update tasks" ON tasks;
DROP POLICY IF EXISTS "Authenticated delete tasks" ON tasks;

CREATE POLICY "Public read all tasks"
ON tasks FOR SELECT
USING (true);

CREATE POLICY "Authenticated insert tasks"
ON tasks FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated update tasks"
ON tasks FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Authenticated delete tasks"
ON tasks FOR DELETE
TO authenticated
USING (true);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.3 USER_TASK_PROGRESS TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can see own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Users can insert own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Users can update own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Users can delete own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Admin can read all progress" ON user_task_progress;

CREATE POLICY "Users read own or admin sees all"
ON user_task_progress FOR SELECT
USING (
  auth.uid() = user_id 
  OR EXISTS (
    SELECT 1 FROM user_roles 
    WHERE user_roles.user_id = auth.uid() 
    AND user_roles.role = 'admin'
  )
);

CREATE POLICY "Users insert own progress"
ON user_task_progress FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own progress"
ON user_task_progress FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users delete own progress"
ON user_task_progress FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.4 INTERVIEW TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can see own interviews" ON interview;
DROP POLICY IF EXISTS "Users can insert interviews" ON interview;
DROP POLICY IF EXISTS "Users can update interviews" ON interview;
DROP POLICY IF EXISTS "Users can delete interviews" ON interview;

CREATE POLICY "Users read own interviews"
ON interview FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users insert interviews"
ON interview FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own interviews"
ON interview FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users delete own interviews"
ON interview FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.5 JOB_READINESS_ASSESSMENTS TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can see own assessments" ON job_readiness_assessments;
DROP POLICY IF EXISTS "Users can insert assessments" ON job_readiness_assessments;
DROP POLICY IF EXISTS "Users can update assessments" ON job_readiness_assessments;
DROP POLICY IF EXISTS "Users can delete assessments" ON job_readiness_assessments;

CREATE POLICY "Users read own assessments"
ON job_readiness_assessments FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users insert assessments"
ON job_readiness_assessments FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own assessments"
ON job_readiness_assessments FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users delete own assessments"
ON job_readiness_assessments FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.6 QUESTIONS TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Public read questions" ON questions;
DROP POLICY IF EXISTS "Authenticated insert questions" ON questions;
DROP POLICY IF EXISTS "Authenticated update questions" ON questions;
DROP POLICY IF EXISTS "Authenticated delete questions" ON questions;

CREATE POLICY "Public read all questions"
ON questions FOR SELECT
USING (true);

CREATE POLICY "Authenticated insert questions"
ON questions FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated update questions"
ON questions FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Authenticated delete questions"
ON questions FOR DELETE
TO authenticated
USING (true);

-- ─────────────────────────────────────────────────────────────────────────
-- 2.7 USER_ROLES TABLE POLICIES
-- ─────────────────────────────────────────────────────────────────────────

DROP POLICY IF EXISTS "Users can see own role" ON user_roles;
DROP POLICY IF EXISTS "Users can see all roles" ON user_roles;
DROP POLICY IF EXISTS "Authenticated insert roles" ON user_roles;
DROP POLICY IF EXISTS "Authenticated update roles" ON user_roles;
DROP POLICY IF EXISTS "Authenticated delete roles" ON user_roles;

CREATE POLICY "Public read all roles"
ON user_roles FOR SELECT
USING (true);

CREATE POLICY "Authenticated insert roles"
ON user_roles FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated update roles"
ON user_roles FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Authenticated delete roles"
ON user_roles FOR DELETE
TO authenticated
USING (true);

-- ============================================================================
-- STEP 3: VERIFICATION
-- ============================================================================

-- Check storage policies
SELECT 
  tablename, 
  policyname, 
  cmd,
  permissive
FROM pg_policies
WHERE tablename = 'objects'
ORDER BY policyname;

-- Check table policies
SELECT 
  schemaname,
  tablename, 
  policyname, 
  cmd,
  permissive
FROM pg_policies
WHERE schemaname = 'public' AND tablename NOT IN ('objects')
ORDER BY tablename, policyname;
