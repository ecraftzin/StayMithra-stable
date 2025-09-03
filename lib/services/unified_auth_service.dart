import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/firebase_config.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import 'firebase_auth_service.dart';
import 'auth_service.dart';

/// Unified authentication service that handles both Firebase and Supabase authentication
/// This service provides a single interface for authentication regardless of the provider
class UnifiedAuthService {
  static final UnifiedAuthService _instance = UnifiedAuthService._internal();
  factory UnifiedAuthService() => _instance;
  UnifiedAuthService._internal();

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final AuthService _supabaseAuthService = AuthService();
  final firebase_auth.FirebaseAuth _firebaseAuth = FirebaseConfig.auth;
  final SupabaseClient _supabase = supabase;

  /// Get the current authenticated user (Firebase takes priority)
  dynamic get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return firebaseUser;
    }
    return _supabase.auth.currentUser;
  }

  /// Check if any user is logged in
  bool get isLoggedIn {
    return _firebaseAuth.currentUser != null || _supabase.auth.currentUser != null;
  }

  /// Get current user profile with unified approach
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser != null) {
        // User is authenticated with Firebase (Google login)
        return await _getFirebaseUserProfile(firebaseUser);
      } else {
        // User is authenticated with Supabase (email/password)
        return await _supabaseAuthService.getCurrentUserProfile();
      }
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  /// Get Firebase user profile from Supabase database
  Future<UserModel?> _getFirebaseUserProfile(firebase_auth.User firebaseUser) async {
    try {
      // First try to get existing profile by firebase_uid
      final response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }

      // If no profile exists, create one from Firebase user data
      await _createFirebaseUserProfile(firebaseUser);
      
      // Try to fetch the newly created profile
      final newResponse = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', firebaseUser.uid)
          .single();

      return UserModel.fromJson(newResponse);
    } catch (e) {
      print('Error getting Firebase user profile: $e');
      return null;
    }
  }

  /// Create a new user profile for Firebase user
  Future<void> _createFirebaseUserProfile(firebase_auth.User firebaseUser) async {
    try {
      await _supabase.from('users').insert({
        'firebase_uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'full_name': firebaseUser.displayName ?? '',
        'username': _generateUsername(firebaseUser.email ?? ''),
        'avatar_url': firebaseUser.photoURL,
        'is_verified': firebaseUser.emailVerified,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating Firebase user profile: $e');
      rethrow;
    }
  }

  /// Generate username from email
  String _generateUsername(String email) {
    if (email.isEmpty) return 'user_${DateTime.now().millisecondsSinceEpoch}';
    final username = email.split('@')[0].toLowerCase();
    return username.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  }

  /// Update user profile (works for both Firebase and Supabase users)
  Future<UserModel?> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? avatarUrl,
    bool updateAvatar = false,
  }) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      
      if (firebaseUser != null) {
        // Update Firebase user profile
        return await _updateFirebaseUserProfile(
          firebaseUser,
          username: username,
          fullName: fullName,
          bio: bio,
          location: location,
          website: website,
          avatarUrl: avatarUrl,
          updateAvatar: updateAvatar,
        );
      } else {
        // Update Supabase user profile
        return await _supabaseAuthService.updateProfile(
          username: username,
          fullName: fullName,
          bio: bio,
          location: location,
          website: website,
          avatarUrl: avatarUrl,
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  /// Update Firebase user profile in Supabase
  Future<UserModel?> _updateFirebaseUserProfile(
    firebase_auth.User firebaseUser, {
    String? username,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? avatarUrl,
    bool updateAvatar = false,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (website != null) updates['website'] = website;
      if (updateAvatar) updates['avatar_url'] = avatarUrl;

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('firebase_uid', firebaseUser.uid)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error updating Firebase user profile: $e');
      rethrow;
    }
  }

  /// Sign out from both Firebase and Supabase
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Sign out from Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  /// Get user by ID (works for both Firebase and Supabase users)
  Future<UserModel?> getUserById(String userId) async {
    try {
      // First try to find by regular ID (Supabase users)
      var response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }

      // If not found, try to find by firebase_uid (Firebase users)
      response = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', userId)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      }

      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }
}
