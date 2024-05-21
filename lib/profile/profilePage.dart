import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/services/authentic.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/background.dart';
import 'package:flutter_application_1/signin/edit_pass_auth.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _SignUpState();
}

class _SignUpState extends State<profile> {
  // Global key for the form
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cnfpasswordController = TextEditingController();

  // Reference to the current user
  var user = AuthService().user;

  // Stream to retrieve therapist data
  late Stream<DocumentSnapshot> therapistStream = FirebaseFirestore.instance
      .collection('Therapist')
      .doc(user!.uid)
      .snapshots();

  // Function to navigate to the change password screen
  void openedit_pass_auth() {
    Navigator.of(context).pushReplacementNamed('edit_pass_auth');
  }

  @override
  void initState() {
    super.initState();

    // Listening to changes in the Therapist collection to update the UI
    FirebaseFirestore.instance
        .collection('Therapist')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(1)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot lastDocument = snapshot.docs.first;
        setState(() {
          therapistStream = FirebaseFirestore.instance
              .collection('Therapist')
              .doc(user!.uid)
              .snapshots();
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cnfpasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
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
              heightFactor: 0.64,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
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
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                            child: Text(
                              'Profile information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                 fontFamily: 'Merriweather'
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(80, 0, 0, 0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 78, 78, 78),
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed('editprofilepage');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // StreamBuilder to get real-time updates on therapist data
                      StreamBuilder<Therapist>(
                        stream: FirestoreService().streamTherapist(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Show a loading indicator while data is being fetched
                            return const Center(child: LoadingPage());
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            // Extract therapist data from the snapshot
                            final therapistData = snapshot.data!;
                            _fullnameController.text = therapistData.name;
                            _emailController.text = therapistData.email;
                            _jobController.text = therapistData.jobTitle;
                            _hospitalController.text =
                                therapistData.hospitalClinic;
                                                    }
                          // Display text form fields for therapist information
                          return Column(
                            children: [
                              TextFormField(
                                enabled: false,
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
                                  prefixIcon: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                enabled: false,
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
                                  prefixIcon: const Icon(
                                    Icons.email,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                enabled: false,
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
                                  prefixIcon: const Icon(
                                    Icons.work,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                enabled: false,
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
                                  prefixIcon: const Icon(
                                    Icons.local_hospital,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255),
                                title: const Text(
                                  'Log out',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromRGBO(0, 0, 0, 1),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('signinScreen');
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color.fromRGBO(
                                            244, 67, 54, 1),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(const Color(0xFF186257)),
                          foregroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 255, 255, 255)),
                          textStyle: MaterialStateProperty.all<TextStyle>(
                            const TextStyle(fontSize: 17),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF186257),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              'Log out',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Merriweather',
                              ),
                            ),
                          ),
                        )
                      ),

                      const SizedBox(height: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Do you want to change your password ? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const edit_pass_auth()),
                              );
                            },
                            child: const Text(
                              'Change password',
                              style: TextStyle(
                                  color: Color(0xFF186257),
                                  fontFamily: 'Merriweather'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
     // bottomNavigationBar: const NavBar(),
    );
  }
}

extension StringValidation on String {
  // Extension to check if the string contains only alphabets
  bool get isAlphaOnly => runes.every(
      (rune) => (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122));
}
