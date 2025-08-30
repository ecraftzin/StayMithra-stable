import 'package:flutter_test/flutter_test.dart';
import 'package:staymitra/services/auth_service.dart';
import 'package:staymitra/config/supabase_config.dart';

void main() {
  group('Forgot Password Tests', () {
    late AuthService authService;

    setUpAll(() async {
      // Initialize Supabase for testing
      await SupabaseConfig.initialize();
      authService = AuthService();
    });

    test('should send password reset email for valid email', () async {
      // Test with a valid email format
      const testEmail = 'test@example.com';
      
      final result = await authService.resetPassword(testEmail);
      
      // Should return success (even if email doesn't exist, for security)
      expect(result['success'], isTrue);
      expect(result['message'], contains('Password reset email sent'));
    });

    test('should handle invalid email format gracefully', () async {
      // Test with invalid email format
      const invalidEmail = 'invalid-email';
      
      final result = await authService.resetPassword(invalidEmail);
      
      // Should return error for invalid email format
      expect(result['success'], isFalse);
      expect(result['message'], contains('Failed to send'));
    });

    test('should handle empty email', () async {
      // Test with empty email
      const emptyEmail = '';
      
      final result = await authService.resetPassword(emptyEmail);
      
      // Should return error for empty email
      expect(result['success'], isFalse);
      expect(result['message'], contains('Failed to send'));
    });
  });

  group('Password Update Tests', () {
    late AuthService authService;

    setUpAll(() async {
      await SupabaseConfig.initialize();
      authService = AuthService();
    });

    test('should validate password update requirements', () async {
      // Test password update (will fail without authenticated user, but tests the method)
      const newPassword = 'newPassword123';
      
      final result = await authService.updatePassword(newPassword);
      
      // Should return error since no user is authenticated
      expect(result['success'], isFalse);
      expect(result['message'], contains('Failed to update password'));
    });
  });
}
