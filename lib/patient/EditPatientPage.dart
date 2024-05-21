import 'package:flutter/material.dart';
import 'package:flutter_application_1/shared/background.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/quickalert.dart';

class EditPatientPage extends StatefulWidget {
  final String pid;
  const EditPatientPage({Key? key, required this.pid}) : super(key: key);

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final _patientnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String selectedGender = '';

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  void fetchPatientData() async {
    DocumentSnapshot patientData = await FirebaseFirestore.instance
        .collection('Patient')
        .doc(widget.pid)
        .get();
    if (patientData.exists) {
      Map<String, dynamic> data = patientData.data() as Map<String, dynamic>;
      _patientnameController.text = data['Patient Name'] ?? '';
      _phoneController.text = data['Phone Number'] ?? '';
      _emailController.text = data['Email'] ?? '';
      selectedGender = data['Gender'] ?? '';
      setState(() {});
    }
  }

  Future<void> updatePatient() async {
    if (_isSubmitting) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        Map<String, dynamic> updatedData = {
          'Patient Name': _patientnameController.text,
          'Phone Number': _phoneController.text,
          'Email': _emailController.text,
          'Gender': selectedGender,
        };

        await FirebaseFirestore.instance
            .collection('Patient')
            .doc(widget.pid)
            .update(updatedData);

        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          text: "Patient information updated successfully!",
        ).then((_) {
          Navigator.pop(context);
        });
      } catch (e) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          text: "An error occurred while updating the patient.",
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 25,
                color: Color(0xFFFFFFFF),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
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
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _patientnameController,
                          decoration: InputDecoration(
                            labelText: 'Patient Name',
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
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: '05XXXXXXXX',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFF186257),
                              ),
                            ),
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone Number is required';
                            } else if (!RegExp(r'^05[0-9]+$').hasMatch(value)) {
                              if (!RegExp(r'^05').hasMatch(value)) {
                                return "Please start your number with '05'";
                              } else {
                                return 'Please enter digits only';
                              }
                            } else if (value.length != 10) {
                              // Check length only if it's a valid pattern
                              return 'Phone number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
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
                            } else if (!EmailValidator.validate(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        ListTile(
                          title: const Text('Male'),
                          leading: Radio<String>(
                            value: 'M',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Female'),
                          leading: Radio<String>(
                            value: 'F',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: updatePatient,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color(0xFF186257)),
                            foregroundColor: MaterialStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Update Patient information',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Merriweather',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
