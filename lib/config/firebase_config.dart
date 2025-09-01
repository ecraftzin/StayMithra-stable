import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Firebase Auth instance
  static firebase_auth.FirebaseAuth get auth => firebase_auth.FirebaseAuth.instance;

  // Google Sign In instance
  static GoogleSignIn get googleSignIn => GoogleSignIn(
    // Web client ID from google-services.json for proper authentication
    serverClientId: '488287009295-8j3vu5gqlmmd77k4l6fsib6mrdtq8f7h.apps.googleusercontent.com',
  );
}

// Global Firebase Auth instance
final firebaseAuth = firebase_auth.FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
