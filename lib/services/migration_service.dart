import 'package:supabase_flutter/supabase_flutter.dart';

class MigrationService {
  static final _supabase = Supabase.instance.client;

  static Future<void> runMigrations() async {
    try {
      print('Running database migrations...');
      
      // Migration 1: Add campaign comments trigger and fix counts
      await _fixCommentCounts();
      
      print('Database migrations completed successfully!');
    } catch (e) {
      print('Migration error: $e');
      // Don't throw error to prevent app from crashing
    }
  }

  static Future<void> _fixCommentCounts() async {
    try {
      // 1. Create campaign comments count function
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          CREATE OR REPLACE FUNCTION update_campaign_comments_count()
          RETURNS TRIGGER AS \$\$
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
          \$\$ LANGUAGE plpgsql;
        '''
      });

      // 2. Create campaign comments trigger
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          DROP TRIGGER IF EXISTS update_campaign_comments_count_trigger ON public.campaign_comments;
          CREATE TRIGGER update_campaign_comments_count_trigger
            AFTER INSERT OR DELETE ON public.campaign_comments
            FOR EACH ROW EXECUTE FUNCTION update_campaign_comments_count();
        '''
      });

      // 3. Fix existing post comment counts
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          UPDATE public.posts 
          SET comments_count = (
            SELECT COUNT(*) 
            FROM public.post_comments 
            WHERE post_comments.post_id = posts.id
          );
        '''
      });

      // 4. Fix existing campaign comment counts
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          UPDATE public.campaigns 
          SET comments_count = (
            SELECT COUNT(*) 
            FROM public.campaign_comments 
            WHERE campaign_comments.campaign_id = campaigns.id
          );
        '''
      });

      // 5. Ensure no null comment counts
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          UPDATE public.posts SET comments_count = 0 WHERE comments_count IS NULL;
          UPDATE public.campaigns SET comments_count = 0 WHERE comments_count IS NULL;
        '''
      });

      print('Comment counts migration completed');
    } catch (e) {
      print('Comment counts migration failed: $e');
      // Try alternative approach without exec_sql
      await _fixCommentCountsAlternative();
    }
  }

  static Future<void> _fixCommentCountsAlternative() async {
    try {
      print('Running alternative comment counts fix...');

      // Only fix a few posts at a time to avoid blocking
      final posts = await _supabase.from('posts').select('id').limit(5);
      for (final post in posts) {
        final postId = post['id'];
        final comments = await _supabase
            .from('post_comments')
            .select('id')
            .eq('post_id', postId);

        if (comments.isNotEmpty) {
          await _supabase
              .from('posts')
              .update({'comments_count': comments.length})
              .eq('id', postId);
        }
      }

      // Only fix a few campaigns at a time to avoid blocking
      final campaigns = await _supabase.from('campaigns').select('id').limit(5);
      for (final campaign in campaigns) {
        final campaignId = campaign['id'];
        final comments = await _supabase
            .from('campaign_comments')
            .select('id')
            .eq('campaign_id', campaignId);

        if (comments.isNotEmpty) {
          await _supabase
              .from('campaigns')
              .update({'comments_count': comments.length})
              .eq('id', campaignId);
        }
      }

      print('Alternative comment counts fix completed');
    } catch (e) {
      print('Alternative comment counts fix failed: $e');
    }
  }
}
