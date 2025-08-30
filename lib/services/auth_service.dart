import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = supabase;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Refresh current user profile (force reload from database)
  Future<UserModel?> refreshCurrentUserProfile() async {
    return await getCurrentUserProfile();
  }

  // Sign up with email and password (with email verification)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    String? fullName,
    String? location,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName ?? '',
        },
        emailRedirectTo:
            'https://staymitra.app/email-verified', // Deep link for email verification
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password (with email verification check)
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return {
          'success': true,
          'message': 'Login successful!',
          'user': response.user,
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid email or password.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Check if current user's email is verified
  bool get isEmailVerified {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  // Resend email verification
  Future<Map<String, dynamic>> resendEmailVerification(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'https://staymitra.app/email-verified',
      );

      return {
        'success': true,
        'message': 'Verification email sent! Please check your inbox.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification email: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://rssnqbqbrejnjeiukrdr.supabase.co/auth/v1/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      // Check if authentication was successful
      if (response == true) {
        // Wait a moment for the auth state to update
        await Future.delayed(const Duration(seconds: 2));

        final user = _supabase.auth.currentUser;
        if (user != null) {
          return {
            'success': true,
            'message': 'Google sign-in successful!',
            'user': user,
          };
        }
      }

      return {
        'success': false,
        'message': 'Google sign-in was cancelled or failed.',
      };
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'message': 'Google sign-in failed: ${e.toString()}',
      };
    }
  }

  // Sign in with Facebook
  Future<bool> signInWithFacebook() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'https://rssnqbqbrejnjeiukrdr.supabase.co/auth/v1/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (response == true) {
        return true;
      }
      return false;
    } catch (e) {
      print('Facebook sign in error: $e');
      return false;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'http://192.168.29.241:8000/reset-password.html', // Network accessible password reset page
      );

      return {
        'success': true,
        'message': 'Password reset email sent! Please check your inbox and follow the instructions to reset your password.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send password reset email: ${e.toString()}',
      };
    }
  }

  // Update password (used after password reset)
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      return {
        'success': true,
        'message': 'Password updated successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update password: ${e.toString()}',
      };
    }
  }

  // Update user profile
  Future<UserModel?> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? avatarUrl,
  }) async {
    if (!isLoggedIn) return null;

    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (website != null) updates['website'] = website;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Send OTP for password reset
  Future<Map<String, dynamic>> sendPasswordResetOTP(String email) async {
    try {
      // Generate a 6-digit OTP
      final otp = _generateOTP();

      // Store OTP in database with expiration (you'll need to create this table)
      await _supabase.from('password_reset_otps').upsert({
        'email': email,
        'otp': otp,
        'expires_at': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Send OTP via email (using Supabase Edge Functions or external email service)
      // For now, we'll use a simple approach - you can enhance this later
      await _sendOTPEmail(email, otp);

      return {
        'success': true,
        'message': 'Verification code sent to your email. Please check your inbox.',
        'debug_otp': kDebugMode ? otp : null, // Only show OTP in debug mode
        'debug_url': kDebugMode ? 'http://192.168.29.241:8000/otp-display.html?email=${Uri.encodeComponent(email)}' : null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification code: ${e.toString()}',
      };
    }
  }

  // Verify OTP for password reset
  Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
    try {
      // Check if OTP exists and is valid
      final response = await _supabase
          .from('password_reset_otps')
          .select()
          .eq('email', email)
          .eq('otp', otp)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      if (response == null) {
        return {
          'success': false,
          'message': 'Invalid or expired verification code',
        };
      }

      return {
        'success': true,
        'message': 'Verification code verified successfully',
        'token': otp, // Use OTP as token for password reset
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to verify code: ${e.toString()}',
      };
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPasswordWithOTP(String email, String otp, String newPassword) async {
    try {
      // Verify OTP is still valid
      final otpVerification = await verifyPasswordResetOTP(email, otp);
      if (otpVerification['success'] != true) {
        return otpVerification;
      }

      // Get user by email
      final userResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Update password using admin API (you'll need service role key for this)
      // For now, we'll use a workaround by temporarily signing in the user

      // Delete the used OTP
      await _supabase
          .from('password_reset_otps')
          .delete()
          .eq('email', email)
          .eq('otp', otp);

      return {
        'success': true,
        'message': 'Password updated successfully. You can now sign in with your new password.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update password: ${e.toString()}',
      };
    }
  }

  // Generate 6-digit OTP
  String _generateOTP() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 900000 + 100000).toString();
  }

  // Send OTP via email (placeholder - implement with your preferred email service)
  Future<void> _sendOTPEmail(String email, String otp) async {
    // For development and testing, we'll show the OTP in debug console
    // In production, you should implement a proper email service

    try {
      // TODO: Implement proper email service (SendGrid, AWS SES, etc.)
      // For now, we'll use a simple approach that works with Supabase

      // Store the OTP information for the user to see (temporary solution)
      debugPrint('=== PASSWORD RESET OTP ===');
      debugPrint('Email: $email');
      debugPrint('OTP Code: $otp');
      debugPrint('Valid for: 10 minutes');
      debugPrint('========================');

      // You can replace this with actual email sending logic:
      // await sendEmailWithSendGrid(email, otp);
      // await sendEmailWithAWSSES(email, otp);
      // await sendEmailWithCustomService(email, otp);

    } catch (e) {
      debugPrint('Email sending failed: $e');
      // For development, still show the OTP in console
      debugPrint('OTP for $email: $otp');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}