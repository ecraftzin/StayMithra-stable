import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- for User/AuthState

import '../config/supabase_config.dart'; // exposes `supabase`
import '../SplashScreen/splashscreen.dart';
import '../MainPage/mainpage.dart';
import '../UserLogin/login.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  User? _user;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();

    // Initial user (works on v2)
    _user = supabase.auth.currentUser;

    // Listen to auth changes
    _authSub = supabase.auth.onAuthStateChange.listen((AuthState state) {
      if (!mounted) return;
      setState(() {
        _user = state.session?.user;
      });
    });

    // Show splash briefly (optional)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // If there's a logged-in user -> MainPage, otherwise -> SignInPage
    return _user != null ? const MainPage() : const SignInPage();
  }
}
