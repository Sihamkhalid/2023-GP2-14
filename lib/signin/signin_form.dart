// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_application_1/services/authentic.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInState();
}

class _SignInState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Firebase authentication state stream
  final userStream = FirebaseAuth.instance.authStateChanges();
  // Current user from FirebaseAuth
  final user = FirebaseAuth.instance.currentUser;

  // Function to navigate to the sign-up screen
  void openSignupScreen() {
    Navigator.of(context).pushReplacementNamed('signupScreen');
  }

  // Function to navigate to the forgot password screen
  void openForgotpasswordScreen() {
    Navigator.of(context).pushReplacementNamed('forgetpasswordScreen');
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    return Form(
      key: _formKey,
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              color: const Color(0xFF186257),
              child: Image.asset(
                "assets/images/background.jpeg",
                height: height,
                fit: BoxFit.contain,
              ),
            ),
            // Form aligned at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Container for sign-in form
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title
                            const Center(
                              child: Text(
                                'Sign in to join',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Merriweather'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Email Input Field
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'xxxx@xxxxx.xx',
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
                            // Password Input Field
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Password',
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
                            const SizedBox(height: 20),
                            // Sign In Button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () {
                                  String email = _emailController.text.trim();
                                  String password =
                                      _passwordController.text.trim();
                                  AuthService().signIn(email, password, context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF186257),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Sign Up and Forgot Password Links
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Don't have an account yet? "),
                                GestureDetector(
                                  onTap: openSignupScreen,
                                  child: const Text(
                                    'Sign up now',
                                    style: TextStyle(
                                      color: Color(0xFF186257),
                                      fontFamily: 'Merriweather',
                                    ),
                                  ),
                                ),
                                Center(
                                  child: GestureDetector(
                                    onTap: openForgotpasswordScreen,
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: Color(0xFF186257),
                                        fontFamily: 'Merriweather',
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
