import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class FirebaseMigrationService {
  static final SupabaseClient _supabase = supabase;

  /// Add firebase_uid column to users table for Firebase integration
  static Future<void> addFirebaseUidColumn() async {
    try {
      // Check if firebase_uid column already exists
      final result = await _supabase.rpc('check_column_exists', params: {
        'table_name': 'users',
        'column_name': 'firebase_uid'
      });

      if (result == false) {
        // Add firebase_uid column
        await _supabase.rpc('add_firebase_uid_column');
        print('✅ Added firebase_uid column to users table');
      } else {
        print('✅ firebase_uid column already exists');
      }
    } catch (e) {
      print('❌ Error adding firebase_uid column: $e');
      
      // Fallback: Try direct SQL if RPC functions don't exist
      try {
        await _supabase.from('users').select('firebase_uid').limit(1);
        print('✅ firebase_uid column already exists (verified by query)');
      } catch (selectError) {
        print('⚠️ firebase_uid column may not exist. Please add it manually in Supabase dashboard.');
        print('SQL to run: ALTER TABLE users ADD COLUMN firebase_uid TEXT UNIQUE;');
      }
    }
  }

  /// Create index on firebase_uid for better performance
  static Future<void> createFirebaseUidIndex() async {
    try {
      await _supabase.rpc('create_firebase_uid_index');
      print('✅ Created index on firebase_uid column');
    } catch (e) {
      print('❌ Error creating firebase_uid index: $e');
      print('SQL to run: CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);');
    }
  }

  /// Run all Firebase-related migrations
  static Future<void> runFirebaseMigrations() async {
    print('🔄 Running Firebase migrations...');
    
    await addFirebaseUidColumn();
    await createFirebaseUidIndex();
    
    print('✅ Firebase migrations completed');
  }
}
