import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  // Function to send a password reset email
  void sendResetPasswordEmail() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Send password reset email using Firebase Auth
        await auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );

        // Show success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please check your email for the password reset link.'),
          ),
        );
      } catch (e) {
        // Handle errors if sending reset email fails
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again later.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey, // Preserve the Form key here
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: const Color(0xFF186257), // Replace with your background color
              child: Image.asset(
                "assets/images/background.jpeg",
                height: height,
                fit: BoxFit.contain,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.35,
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
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            ' Write your email to change the password',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Merriweather',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Email input field with validation
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'xxxx@xxxxx.xx',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257), // Blue border in hex
                              ),
                            ),
                            prefixIcon: const Icon(Icons.email), // Icon for email
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            } else if (!EmailValidator.validate(value) ||
                                RegExp(r'^[A-Za-z][A-Za-z0-9]*$').hasMatch(value)) {
                              return 'Enter a valid email';
                            } else {
                              // You should add logic to check if the email is already in the database here.
                              // If it is repeated, return an error message.
                              // For now, return null as a placeholder.
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        const SizedBox(height: 15),
                        // Send button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: GestureDetector(
                            onTap: sendResetPasswordEmail,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF186257),
                                borderRadius: BorderRadius.circular(15), // Rounded borders
                              ),
                              child: const Center(
                                child: Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Merriweather', // White text color
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
              ),
            ),
            // Back button
            Positioned(
              top: 25,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
