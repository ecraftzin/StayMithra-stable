-- Fix comment counts migration
-- This script fixes the double counting issue and adds missing triggers

-- 1. Create campaign comments count function and trigger
CREATE OR REPLACE FUNCTION update_campaign_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.campaigns SET comments_count = comments_count + 1 WHERE id = NEW.campaign_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.campaigns SET comments_count = comments_count - 1 WHERE id = OLD.campaign_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if it exists and recreate
DROP TRIGGER IF EXISTS update_campaign_comments_count_trigger ON public.campaign_comments;
CREATE TRIGGER update_campaign_comments_count_trigger
  AFTER INSERT OR DELETE ON public.campaign_comments
  FOR EACH ROW EXECUTE FUNCTION update_campaign_comments_count();

-- 2. Fix existing comment counts by recalculating them from actual comments
-- Fix post comment counts
UPDATE public.posts 
SET comments_count = (
  SELECT COUNT(*) 
  FROM public.post_comments 
  WHERE post_comments.post_id = posts.id
);

-- Fix campaign comment counts  
UPDATE public.campaigns 
SET comments_count = (
  SELECT COUNT(*) 
  FROM public.campaign_comments 
  WHERE campaign_comments.campaign_id = campaigns.id
);

-- 3. Ensure all posts and campaigns have a comments_count value (not null)
UPDATE public.posts SET comments_count = 0 WHERE comments_count IS NULL;
UPDATE public.campaigns SET comments_count = 0 WHERE comments_count IS NULL;
