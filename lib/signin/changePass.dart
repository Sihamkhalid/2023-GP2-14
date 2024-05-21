import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class changePass extends StatefulWidget {
  const changePass({super.key});

  @override
  State<changePass> createState() => _SignInState();
}

class _SignInState extends State<changePass> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _cnfpasswordController = TextEditingController();

  Future<void> changePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // Update the user's password using Firebase Authentication
      await user!.updatePassword(newPassword);
      print("Password updated successfully");
      Navigator.of(context).pushNamed('profilepage');
    } catch (e) {
      print("Failed to update password: $e");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _cnfpasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF186257),
          elevation: 0.0,
        ),
        body: Stack(
          children: [
            // Background Image
            Container(
              color: const Color(0xFF186257),
              child: Image.asset(
                "assets/images/background.jpeg",
                height: height,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Password Change Form
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            const Center(
                              child: Text(
                                'Enter new password',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Merriweather',
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Password Input
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                            // Confirm Password Input
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: GestureDetector(
                                onTap: () {
                                  changePassword(_passwordController
                                      .text); // Call changePassword asynchronously
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF186257),
                                    borderRadius: BorderRadius.circular(
                                        15), // Rounded borders
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        //fontFamily: 'Merriweather', // White text color
                                      ),
                                    ),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
