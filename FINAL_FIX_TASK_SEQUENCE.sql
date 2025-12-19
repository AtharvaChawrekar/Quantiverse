-- FINAL FIX: Properly set sequence for all tasks based on their titles

-- Step 1: Add sequence column if it doesn't exist
ALTER TABLE public.tasks
ADD COLUMN IF NOT EXISTS sequence INTEGER;

-- Step 2: Create a proper mapping for all tasks
UPDATE public.tasks
SET sequence = CASE 
  WHEN title = 'Task One' THEN 1
  WHEN title = 'Task Two' THEN 2
  WHEN title = 'Task Three' THEN 3
  WHEN title = 'Task Four' THEN 4
  WHEN title = 'Task Five' THEN 5
  WHEN title = 'Task Six' THEN 6
  WHEN title = 'Task Seven' THEN 7
  WHEN title = 'Task Eight' THEN 8
  WHEN title = 'Task Nine' THEN 9
  WHEN title = 'Task Ten' THEN 10
  ELSE id  -- Fallback to ID
END;

-- Step 3: Make sure no sequence is NULL
UPDATE public.tasks
SET sequence = id
WHERE sequence IS NULL;

-- Step 4: Verify the fix
SELECT id, simulation_id, title, sequence 
FROM public.tasks 
ORDER BY simulation_id, sequence;
