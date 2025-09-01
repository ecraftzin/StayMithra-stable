import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/firebase_config.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseConfig.auth;
  final GoogleSignIn _googleSignIn = FirebaseConfig.googleSignIn;
  final SupabaseClient _supabase = supabase;

  // Get current Firebase user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentFirebaseUser != null;

  // Get current user profile from Supabase (using Firebase UID)
  Future<UserModel?> getCurrentUserProfile() async {
    if (!isLoggedIn) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', currentFirebaseUser!.uid)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Sign in with Google using Firebase
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google sign-in was cancelled.',
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Create or update user profile in Supabase
        await _createOrUpdateUserProfile(firebaseUser);

        return {
          'success': true,
          'message': 'Google sign-in successful!',
          'user': firebaseUser,
        };
      }

      return {
        'success': false,
        'message': 'Failed to sign in with Google.',
      };
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'message': 'Google sign-in failed: ${e.toString()}',
      };
    }
  }

  // Create or update user profile in Supabase
  Future<void> _createOrUpdateUserProfile(User firebaseUser) async {
    try {
      // Check if user already exists
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      if (existingUser == null) {
        // Create new user profile
        await _supabase.from('users').insert({
          'firebase_uid': firebaseUser.uid,
          'email': firebaseUser.email,
          'full_name': firebaseUser.displayName ?? '',
          'username': _generateUsername(firebaseUser.email ?? ''),
          'avatar_url': firebaseUser.photoURL,
          'is_verified': firebaseUser.emailVerified,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // Update existing user profile
        await _supabase
            .from('users')
            .update({
              'email': firebaseUser.email,
              'full_name': firebaseUser.displayName ?? existingUser['full_name'],
              'avatar_url': firebaseUser.photoURL ?? existingUser['avatar_url'],
              'is_verified': firebaseUser.emailVerified,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('firebase_uid', firebaseUser.uid);
      }
    } catch (e) {
      print('Error creating/updating user profile: $e');
    }
  }

  // Generate username from email
  String _generateUsername(String email) {
    final username = email.split('@')[0].toLowerCase();
    return username.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = currentFirebaseUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      // Delete user profile from Supabase
      await _supabase
          .from('users')
          .delete()
          .eq('firebase_uid', user.uid);

      // Delete Firebase account
      await user.delete();

      return {
        'success': true,
        'message': 'Account deleted successfully.',
      };
    } catch (e) {
      print('Error deleting account: $e');
      return {
        'success': false,
        'message': 'Failed to delete account: ${e.toString()}',
      };
    }
  }

  // Get auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
