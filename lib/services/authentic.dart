import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/bottom_nav.dart';

class AuthService {
  // Stream for monitoring changes in the authentication state
  final userStream = FirebaseAuth.instance.authStateChanges();
  // Get the current user
  final user = FirebaseAuth.instance.currentUser;

  // Sign out method
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Email and password sign-in method
  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Redirect to homepage after successful login
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNavBar()));
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
          // Display error message for incorrect email or password
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('The email or password is incorrect ')));
        } else {
          // Handle other FirebaseAuthException errors or display a generic error message.
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred: ${e.message}')));
        }
      }
    }
  }
}