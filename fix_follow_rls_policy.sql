-- Fix RLS policy for follows table to allow both follower and following to create relationships
-- This fixes the "Failed to accept follow request" issue

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Users can create follows" ON public.follows;

-- Create the new policy that allows both parties to create follow relationships
-- This is needed because when accepting a follow request, the accepter (following_id) 
-- creates the relationship, not the requester (follower_id)
CREATE POLICY "Users can create follows" ON public.follows FOR INSERT WITH CHECK (
  auth.uid() = follower_id OR auth.uid() = following_id
);

-- Verify the policy was created correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'follows' AND policyname = 'Users can create follows';
