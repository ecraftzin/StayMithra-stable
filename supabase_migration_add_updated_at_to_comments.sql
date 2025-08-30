-- Migration: Add updated_at column to comment tables
-- This fixes the issue where comments couldn't be created due to missing updated_at column

-- Add updated_at column to post_comments table
ALTER TABLE public.post_comments 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Add updated_at column to campaign_comments table  
ALTER TABLE public.campaign_comments 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Update existing records to have updated_at = created_at
UPDATE public.post_comments 
SET updated_at = created_at 
WHERE updated_at IS NULL;

UPDATE public.campaign_comments 
SET updated_at = created_at 
WHERE updated_at IS NULL;

-- Create triggers to automatically update updated_at when records are modified
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for both comment tables
DROP TRIGGER IF EXISTS update_post_comments_updated_at ON public.post_comments;
CREATE TRIGGER update_post_comments_updated_at
    BEFORE UPDATE ON public.post_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_campaign_comments_updated_at ON public.campaign_comments;
CREATE TRIGGER update_campaign_comments_updated_at
    BEFORE UPDATE ON public.campaign_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
