// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/authentic.dart';

// Define a StatefulWidget for the 'edit_pass_auth' screen
class edit_pass_auth extends StatefulWidget {
  const edit_pass_auth({super.key});

  @override
  State<edit_pass_auth> createState() => _SignInState();
}

// Define the corresponding State class for the 'edit_pass_auth' screen
class _SignInState extends State<edit_pass_auth> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Retrieve the current user from the authentication service
  var user = AuthService().user;

  // Stream to monitor changes in the therapist document
  late Stream<DocumentSnapshot> therapistStream = FirebaseFirestore.instance
      .collection('Therapist')
      .doc(user!.uid)
      .snapshots();

  // Function to navigate to the 'changePass' page
  Future next() async {
    try {
      // Signing in with provided email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navigating to 'changePass' page upon successful sign-in
      Navigator.of(context).pushNamed('changePass');
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'INVALID_CREDENTIALS') {
          // Showing a snackbar for incorrect email or password
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('The email or password is incorrect ')));
        } else {
          // Handling other FirebaseAuthException errors or displaying a generic error message.
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('An error occurred: ${e.message}')));
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
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
        appBar: AppBar(
          backgroundColor: Color(0xFF186257),
          elevation: 0.0,
        ),
        body: Stack(
          children: [
            // Background Image
            Container(
              color: Color(0xFF186257),
              child: Image.asset(
                "assets/images/background.jpeg",
                height: height,
                fit: BoxFit.contain,
              ),
            ),
            // Form Body
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Form Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                'Enter your current password',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Merriweather',
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // StreamBuilder to display the user's email
                            StreamBuilder<DocumentSnapshot>(
                              stream: therapistStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  final therapistData = snapshot.data!.data();
                                  if (therapistData != null) {
                                    _emailController.text =
                                        therapistData is Map<String, dynamic>
                                            ? therapistData['Email']
                                            : '';
                                  }
                                }
                                return TextFormField(
                                  readOnly: true,
                                  initialValue: user!.email,
                                  decoration: InputDecoration(
                                    enabled: false,
                                    labelText: 'Email',
                                    hintText: 'xxxx@xxxxx.xx',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Color(0xFF186257),
                                      ),
                                    ),
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
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
                                  borderSide: BorderSide(
                                    color: Color(0xFF186257),
                                  ),
                                ),
                                prefixIcon: Icon(Icons.lock),
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
                            SizedBox(height: 20),
                            // Next Button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: GestureDetector(
                                onTap: next,
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF186257),
                                    borderRadius: BorderRadius.circular(
                                        15), // Rounded borders
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Next',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
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
