import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ixqjqfqjqfqjqfqjqfqj.supabase.co', // Replace with your URL
    anonKey: 'your-anon-key', // Replace with your anon key
  );

  final supabase = Supabase.instance.client;

  try {
    print('Running comment counts migration...');

    // Read the SQL file
    final sqlContent = await File('fix_comment_counts.sql').readAsString();
    
    // Split by semicolons and execute each statement
    final statements = sqlContent.split(';').where((s) => s.trim().isNotEmpty);
    
    for (final statement in statements) {
      if (statement.trim().isNotEmpty) {
        print('Executing: ${statement.trim().substring(0, 50)}...');
        await supabase.rpc('exec_sql', params: {'sql': statement.trim()});
      }
    }

    print('Migration completed successfully!');
  } catch (e) {
    print('Migration failed: $e');
  }
}
