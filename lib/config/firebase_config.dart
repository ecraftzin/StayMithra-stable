import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }
  
  // Firebase Auth instance
  static FirebaseAuth get auth => FirebaseAuth.instance;
  
  // Google Sign In instance
  static GoogleSignIn get googleSignIn => GoogleSignIn(
    // Use the client ID from your google-services.json
    // This will be automatically configured
  );
}

// Global Firebase Auth instance
final firebaseAuth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();
