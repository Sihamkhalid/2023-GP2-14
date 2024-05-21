import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/authentic.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/background.dart';

class editprofile extends StatefulWidget {
  const editprofile({super.key});

  @override
  State<editprofile> createState() => _SignUpState();
}

class _SignUpState extends State<editprofile> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for UI display
  final _displayFullnameController = TextEditingController();
  final _displayEmailController = TextEditingController();
  final _displayJobController = TextEditingController();
  final _displayHospitalController = TextEditingController();

  // Controllers for database storage
  final _storeFullnameController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _storeJobController = TextEditingController();
  final _storeHospitalController = TextEditingController();

  // Reference to the current user
  var user = AuthService().user;

  // Stream to retrieve therapist data
  late Stream<DocumentSnapshot> therapistStream = FirebaseFirestore.instance
      .collection('Therapist')
      .doc(user!.uid)
      .snapshots();

  // Function to initialize UI controllers and listeners
  @override
  void initState() {
    super.initState();

    // Initialize StreamBuilder with controllers for UI display
    therapistStream = FirebaseFirestore.instance
        .collection('Therapist')
        .doc('JzhiqlmRT8qd3IX65cGr') // Replace with actual user ID
        .snapshots();

    // Add listener to update UI controllers
    _storeFullnameController.addListener(() {
      _displayFullnameController.text = _storeFullnameController.text;
    });

    _storeEmailController.addListener(() {
      _displayEmailController.text = _storeEmailController.text;
    });

    _storeJobController.addListener(() {
      _displayJobController.text = _storeJobController.text;
    });

    _storeHospitalController.addListener(() {
      _displayHospitalController.text = _storeHospitalController.text;
    });
  }

  // Function to save therapist data to the database
  Future<void> saveTherapistData() async {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('Therapist');
    final DocumentReference document = collection.doc(user!.uid);

    // Fetch the existing document
    final DocumentSnapshot snapshot = await document.get();

    if (snapshot.exists) {
      // Get the existing data as a Map
      Map<String, dynamic> existingData =
          snapshot.data() as Map<String, dynamic>;

      // Remove the fields you want to "delete"
      existingData.remove('Full name');
      existingData.remove('Email');
      existingData.remove('HospitalClinic');
      existingData.remove('Job Title');

      // Add the fields with new values
      existingData['Full name'] = _displayFullnameController.text;
      existingData['Email'] = _displayEmailController.text;
      existingData['HospitalClinic'] = _displayHospitalController.text;
      existingData['Job Title'] = _displayJobController.text;

      // Update the document with the modified data
      await document.set(existingData);

      // Navigate to the change password screen after saving
      Navigator.of(context).pushReplacementNamed('edit_pass_auth');
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
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              color: const Color(0xFF186257),
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(
                          child: Text(
                            'Profile information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // StreamBuilder to get real-time updates on therapist data
                        StreamBuilder<Therapist>(
                          stream: FirestoreService().streamTherapist(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              final therapistData = snapshot.data!;
                              _storeFullnameController.text =
                                  therapistData.name;
                              _storeEmailController.text =
                                  therapistData.email;
                              _storeJobController.text =
                                  therapistData.jobTitle;
                              _storeHospitalController.text =
                                  therapistData.hospitalClinic;
                                                        }
                            // Display text form fields for therapist information
                            return Column(
                              children: [
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _displayFullnameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF186257),
                                      ),
                                    ),
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
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _displayEmailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'xxxx@xxxxx.xx',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF186257),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    } else if (!EmailValidator.validate(
                                            value) ||
                                        RegExp(r'^[A-Za-z][A-Za-z0-9]*$')
                                            .hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    controller: _displayJobController,
                                    decoration: InputDecoration(
                                      labelText: 'Job Title',
                                      hintText: 'Physical Therapist',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF186257),
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Job Title is required';
                                      } else if (!RegExp(r'^[a-zA-Z\s]+$')
                                          .hasMatch(value)) {
                                        return 'Job Title should only contain alphabetic characters';
                                      }
                                      return null;
                                    }),
                                const SizedBox(height: 10),
                                TextFormField(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: _displayHospitalController,
                                  decoration: InputDecoration(
                                    labelText: 'Hospital/Clinic',
                                    hintText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF186257),
                                      ),
                                    ),
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
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Validate the form and save therapist data
                            if (_formKey.currentState!.validate()) {
                              saveTherapistData();
                              Navigator.pop(context);
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(const Color(0xFF186257)),
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
                            'Save',
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
    //  bottomNavigationBar: const NavBar(),
    );
  }
}

// Extension to check if the string contains only alphabets
extension StringValidation on String {
  bool get isAlphaOnly => runes.every(
      (rune) => (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122));
}
