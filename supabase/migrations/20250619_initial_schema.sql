-- Drop existing tables in reverse order of creation to handle dependencies
-- The old 'routine_blocks' table might still exist if a reset failed.
DROP TABLE IF EXISTS routine_blocks;
DROP TABLE IF EXISTS user_progress;
DROP TABLE IF EXISTS blocks;
DROP TABLE IF EXISTS routines;

-- Create the 'routines' table
CREATE TABLE routines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create the 'blocks' table
-- This table is denormalized for simplicity. Each block belongs to one routine.
CREATE TABLE blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    routine_id UUID NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    instruction TEXT NOT NULL,
    duration INTEGER NOT NULL,
    block_order INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create the 'user_progress' table
CREATE TABLE user_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    routine_id UUID NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    duration_secs INTEGER NOT NULL
);

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_progress ENABLE ROW LEVEL SECURITY;

-- POLICIES
-- Allow public read access to routines and their blocks
CREATE POLICY "Allow public read access to routines" ON routines FOR SELECT USING (true);
CREATE POLICY "Allow public read access to blocks" ON blocks FOR SELECT USING (true);

-- Allow users to view their own progress
CREATE POLICY "Allow users to view their own progress" ON user_progress FOR SELECT USING (auth.uid() = user_id);

-- Allow users to insert their own progress
CREATE POLICY "Allow users to insert their own progress" ON user_progress FOR INSERT WITH CHECK (auth.uid() = user_id);