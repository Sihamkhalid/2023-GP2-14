// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/authentic.dart';
import '../shared/background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpState();
}

// Function to hash the password using HMAC-SHA256
String hashPassword(String password, String salt) {
  final key = utf8.encode(salt);
  final bytes = utf8.encode(password);
  final hmacSha256 = Hmac(sha256, key);
  final digest = hmacSha256.convert(bytes);
  return digest.toString();
}

class _SignUpState extends State<SignUpForm> {
  // Hashed password for demonstration purposes
  String hashedPassword = hashPassword('user_password', 'unique_salt');

  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnfpasswordController = TextEditingController();
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = AuthService().user;

  // Function to handle the sign-up process
  Future signUp() async {
    try {
      // Create a new user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Data to be stored in Firestore
      Map<String, String> dataToSave = {
        'Full name': _fullnameController.text,
        'Email': _emailController.text,
        'Job Title': _jobController.text,
        'HospitalClinic': _hospitalController.text,
        'Password': hashedPassword,
      };

      // Save data to Firestore under the 'Therapist' collection
      await FirebaseFirestore.instance
          .collection('Therapist')
          .doc(uid)
          .set(dataToSave);

      // Navigate to the homepage after successful sign-up
      Navigator.of(context).pushNamed('homepage');
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          // Display a snackbar for duplicate email address
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'The email address is already in use by another account.')));
        } else {
          // Handle other FirebaseAuthException errors or display a generic error message.
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred: ${e.message}')));
        }
      }
    }
  }

  // Function to navigate to the sign-in screen
  void openSignInScreen() {
    Navigator.of(context).pushReplacementNamed('signinScreen');
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _cnfpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Stack(
          children: [
            // Background Widget
            const Background(),
            // Colored Container at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                color: const Color(0xFF186257),
              ),
            ),
            // Form Content
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.6,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Center(
                          child: Text(
                            'Sign up for an account',
                            style: TextStyle(
                              fontFamily: 'Merriweather',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Full Name Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _fullnameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full name is required';
                            } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                .hasMatch(value)) {
                              return 'Full name should only contain alphabetic characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Email Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'xxxx@xxxxx.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else if (!EmailValidator.validate(value) ||
                                RegExp(r'^[A-Za-z][A-Za-z0-9]*$')
                                    .hasMatch(value)) {
                              return 'Enter a valid email';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        // Job Title Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _jobController,
                          decoration: InputDecoration(
                            labelText: 'Job Title',
                            hintText: 'Physical Therapist',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.work),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Job Title is required';
                            } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                .hasMatch(value)) {
                              return 'Job Title should only contain alphabetic characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Hospital/Clinic Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _hospitalController,
                          decoration: InputDecoration(
                            labelText: 'Hospital/Clinic',
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.local_hospital),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Hospital/Clinic is required';
                            } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                .hasMatch(value)) {
                              return 'Hospital/Clinic should only contain alphabetic characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Password Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: true,
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Confirm Password Input Field
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: true,
                          controller: _cnfpasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            } else if (_cnfpasswordController.text !=
                                _passwordController.text) {
                              return 'Password does not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Sign Up Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: GestureDetector(
                            onTap: signUp,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF186257),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Merriweather',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Sign In Link
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: openSignInScreen,
                              child: const Text(
                                'Sign In here',
                                style: TextStyle(
                                  color: Color(0xFF186257),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to add an "isAlphaOnly" property to strings
extension StringValidation on String {
  bool get isAlphaOnly =>
      runes.every((rune) => (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122));
}
