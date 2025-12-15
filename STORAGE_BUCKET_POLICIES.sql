-- ============================================================================
-- STORAGE BUCKET SETUP AND POLICIES
-- Run this in Supabase SQL Editor after creating the buckets
-- ============================================================================

-- IMPORTANT: First, manually create these buckets in Supabase Dashboard:
-- 1. Go to Storage in Supabase Dashboard
-- 2. Create these 3 buckets (make them PUBLIC):
--    - resumes
--    - submissions  
--    - task-materials

-- After creating the buckets, run the policies below:

-- ============================================================================
-- SUBMISSIONS BUCKET POLICIES (for task uploads)
-- ============================================================================

-- Allow authenticated users to upload their own files
CREATE POLICY "Users can upload their own submissions"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'submissions' 
  AND (storage.foldername(name))[1] = 'task-submissions'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- Allow users to view their own submissions
CREATE POLICY "Users can view their own submissions"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'submissions'
  AND (storage.foldername(name))[1] = 'task-submissions'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- Allow users to update/replace their own submissions
CREATE POLICY "Users can update their own submissions"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'submissions'
  AND (storage.foldername(name))[1] = 'task-submissions'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- Allow users to delete their own submissions
CREATE POLICY "Users can delete their own submissions"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'submissions'
  AND (storage.foldername(name))[1] = 'task-submissions'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- ============================================================================
-- RESUMES BUCKET POLICIES
-- ============================================================================

-- Allow authenticated users to upload their own resumes
CREATE POLICY "Users can upload their own resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'resumes'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- Allow users to view their own resumes
CREATE POLICY "Users can view their own resumes"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'resumes'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- Allow users to delete their own resumes
CREATE POLICY "Users can delete their own resumes"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'resumes'
  AND auth.uid()::text = (regexp_split_to_array(storage.filename(name), '_'))[1]
);

-- ============================================================================
-- TASK-MATERIALS BUCKET POLICIES (public read for all authenticated users)
-- ============================================================================

-- Allow anyone authenticated to view task materials
CREATE POLICY "Authenticated users can view task materials"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'task-materials');

-- Only admins should upload task materials (you'll need to add admin check)
CREATE POLICY "Admins can upload task materials"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'task-materials'
  -- Add admin check here if you have admin role system
);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check if policies were created:
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
ORDER BY policyname;

-- ============================================================================
-- NOTES
-- ============================================================================

/*
FILE NAMING CONVENTION:
- Submissions: task-submissions/{userId}_{taskId}_{timestamp}.{extension}
- Resumes: {userId}_{timestamp}.{extension}
- Task Materials: Any structure (managed by admins)

BUCKET SETTINGS (Set in Dashboard):
- All buckets should be marked as PUBLIC
- Max file size: Set appropriate limits (e.g., 10MB for submissions, 5MB for resumes)
- Allowed MIME types: Set based on your needs (PDF, images, etc.)

TROUBLESHOOTING:
If you get 400 errors:
1. Make sure buckets exist and are PUBLIC
2. Make sure RLS is enabled on storage.objects
3. Check that file naming matches the policy patterns
4. Verify user is authenticated (check auth.uid())
*/
