-- ============================================================================
-- QUICK FIX: user_task_progress RLS Policies
-- Run this in Supabase SQL Editor to fix the 403 error
-- ============================================================================

-- Make sure RLS is enabled
ALTER TABLE user_task_progress ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can view their own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Users can insert their own progress" ON user_task_progress;
DROP POLICY IF EXISTS "Users can update their own progress" ON user_task_progress;

-- Create new policies
CREATE POLICY "Users can view their own progress" ON user_task_progress
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress" ON user_task_progress
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress" ON user_task_progress
  FOR UPDATE USING (auth.uid() = user_id);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'user_task_progress';
