import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- for User/AuthState

import '../config/supabase_config.dart'; // exposes `supabase`
import '../config/firebase_config.dart';
import '../SplashScreen/splashscreen.dart';
import '../MainPage/mainpage.dart';
import '../UserLogin/login.dart';
import '../services/firebase_migration_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  firebase_auth.User? _firebaseUser;
  User? _supabaseUser;
  StreamSubscription<firebase_auth.User?>? _firebaseAuthSub;
  StreamSubscription<AuthState>? _supabaseAuthSub;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Run Firebase migrations
    await FirebaseMigrationService.runFirebaseMigrations();

    // Get initial Firebase user
    _firebaseUser = FirebaseConfig.auth.currentUser;

    // Get initial Supabase user (for backward compatibility)
    _supabaseUser = supabase.auth.currentUser;

    // Listen to Firebase auth changes (primary)
    _firebaseAuthSub = FirebaseConfig.auth.authStateChanges().listen((firebase_auth.User? user) {
      if (!mounted) return;
      setState(() {
        _firebaseUser = user;
      });
    });

    // Listen to Supabase auth changes (for existing users)
    _supabaseAuthSub = supabase.auth.onAuthStateChange.listen((AuthState state) {
      if (!mounted) return;
      setState(() {
        _supabaseUser = state.session?.user;
      });
    });

    // Show splash briefly
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _firebaseAuthSub?.cancel();
    _supabaseAuthSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // Check if user is logged in (Firebase takes priority, fallback to Supabase)
    final bool isLoggedIn = _firebaseUser != null || _supabaseUser != null;

    return isLoggedIn ? const MainPage() : const SignInPage();
  }
}
