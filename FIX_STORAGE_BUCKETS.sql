-- ============================================================================
-- QUICK FIX: Enable Storage Bucket Access
-- Run this AFTER creating the buckets in Supabase Dashboard
-- ============================================================================

-- Step 1: Create the buckets first (do this in Supabase Dashboard UI)
-- Go to Storage → New Bucket → Create these 3 buckets:
-- 1. "submissions" (make it PUBLIC)
-- 2. "resumes" (make it PUBLIC)
-- 3. "task-materials" (make it PUBLIC)

-- Step 2: After creating buckets, run this SQL to add policies:

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow authenticated uploads to submissions" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated reads from submissions" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated updates to submissions" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated deletes from submissions" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads to resumes" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated reads from resumes" ON storage.objects;

-- Allow authenticated users to upload to submissions bucket
CREATE POLICY "Allow authenticated uploads to submissions"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'submissions');

-- Allow authenticated users to read from submissions bucket
CREATE POLICY "Allow authenticated reads from submissions"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'submissions');

-- Allow authenticated users to update in submissions bucket
CREATE POLICY "Allow authenticated updates to submissions"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'submissions');

-- Allow authenticated users to delete from submissions bucket
CREATE POLICY "Allow authenticated deletes from submissions"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'submissions');

-- Same policies for resumes bucket
CREATE POLICY "Allow authenticated uploads to resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'resumes');

CREATE POLICY "Allow authenticated reads from resumes"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'resumes');

-- Verify policies were created
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'objects' AND policyname LIKE '%submissions%';
