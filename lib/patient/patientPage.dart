import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/patient/EditPatientPage.dart';
import 'package:flutter_application_1/patient/ReportsHistory.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/nav_bar.dart';
import '../services/models.dart';
import '../services/firestore.dart';
import '../patient/programPage.dart';

class PatientPage extends StatefulWidget {
  // Constructor for PatientPage
  final String pid;
  const PatientPage({Key? key, required this.pid}) : super(key: key);

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  bool _isProgramButtonClicked = false;
  bool _isReportButtonClicked = false;
  bool isLoading = true;

  void loading() {
    Future.delayed(Duration(seconds: 4), () {});
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading();
  }

  Future<void> deletePatient(String pid) async {
    // Display a confirmation dialog before deleting the article
    bool? deleteConfirmed = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this patient?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Color.fromRGBO(244, 67, 54, 1)),
              ),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        // Deleting the article from Firestore
        await FirebaseFirestore.instance
            .collection('Patient')
            .doc(pid)
            .delete();
        Navigator.of(context).pushNamed('homepage');
        QuickAlert.show(
          context: context,
          text: "The patient is deleted successfully!",
          type: QuickAlertType.success,
        );
      } catch (e) {
        // Handling deletion error
        print('Error deleting patient: $e');
        QuickAlert.show(
          context: context,
          text: "Failed to delete the patient!",
          type: QuickAlertType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF186257),
     // bottomNavigationBar: const NavBar(),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Patient avatar and name display
                            Container(
                              child: StreamBuilder<Patient>(
                                stream: FirestoreService()
                                    .streamPatient(widget.pid),
                                builder: (context, snapshot) {
                                  Patient p = snapshot.data!;
                                  String name = p.name;
                                  String gender = p.gender;
                                  String avatar = 'man';
                                  switch (gender) {
                                    case 'F':
                                      avatar = 'woman';
                                      break;
                                    case 'M':
                                      avatar = 'man';
                                      break;
                                  }
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'images/$avatar.png',
                                          height: 120,
                                          width: 120,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Patient information section
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      child: Align(
                        child: FractionallySizedBox(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 1000,
                            color: Colors.grey[100],
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                 crossAxisAlignment:CrossAxisAlignment.center,
                                    children: [
                                      const Center(
                                        child: Text(
                                          'Patient Details',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Merriweather',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 135),
                                      PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          switch (value) {
                                            case 'Edit':
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPatientPage(
                                                          pid: widget.pid),
                                                  // AddProgramPage()
                                                ),
                                              );
                                              break;
                                            case 'Delete':
                                              deletePatient(widget.pid);
                                              break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'Edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'Delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Color.fromARGB(255, 8, 8, 8),
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 35),
                                  // Display patient information
                                  StreamBuilder<Patient>(
                                    stream: FirestoreService()
                                        .streamPatient(widget.pid),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'),
                                        );
                                      }
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const LoadingPage();
                                      }

                                      Patient p = snapshot.data!;
                                      String name = p.name;
                                      String email = p.email;
                                      String phone = p.phone;

                                      return SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            // Display patient details
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  width: 25,
                                                ),
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Row(
                                                        children: [
                                                          // Text(
                                                          //   'Patient Information',
                                                          //   style: TextStyle(
                                                          //     fontSize: 18,
                                                          //     fontWeight:
                                                          //         FontWeight
                                                          //             .bold,
                                                          //     fontFamily:
                                                          //         'Merriweather',
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 13),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Name: ',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            name,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Patient Number: ',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            widget.pid,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Phone Number: ',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            phone,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Email: ',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            email,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 150,
                                                ),
                                                // Contact options
                                                GestureDetector(
                                                  onTap: () async {
                                                    await showModalBottomSheet(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              ListTile(
                                                                leading: const Icon(
                                                                    Icons
                                                                        .message),
                                                                title: const Text(
                                                                    'Send SMS'),
                                                                onTap:
                                                                    () async {
                                                                  final phoneNumber =
                                                                      '+966$phone';
                                                                  final url =
                                                                      'sms:$phoneNumber';

                                                                  if (await canLaunch(
                                                                      url)) {
                                                                    await launch(
                                                                        url);
                                                                  } else {
                                                                    throw 'Could not launch $url';
                                                                  }

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              ListTile(
                                                                leading: const Icon(
                                                                    Icons
                                                                        .email),
                                                                title: const Text(
                                                                    'Send Email'),
                                                                onTap:
                                                                    () async {
                                                                  final url =
                                                                      'mailto:$email';

                                                                  if (await canLaunch(
                                                                      url)) {
                                                                    await launch(
                                                                        url);
                                                                  } else {
                                                                    throw 'Could not launch $url';
                                                                  }

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                              ListTile(
                                                                leading: const Icon(
                                                                    Icons
                                                                        .phone),
                                                                title: const Text(
                                                                    'WhatsApp'),
                                                                onTap:
                                                                    () async {
                                                                  final phoneNumber =
                                                                      '+966$phone';
                                                                  final url =
                                                                      'https://api.whatsapp.com/send?phone=$phoneNumber';

                                                                  if (await canLaunch(
                                                                      url)) {
                                                                    await launch(
                                                                        url);
                                                                  } else {
                                                                    throw 'Could not launch $url';
                                                                  }

                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Image.asset(
                                                    'images/contact.png',
                                                    height: 100,
                                                    width: 100,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 80),
                                  // Program information and Generated reports sections
                                  SizedBox(
                                    height: 150,
                                    width: 700,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Material(
                                              elevation: _isProgramButtonClicked
                                                  ? 0
                                                  : 5,
                                              shadowColor:
                                                  _isProgramButtonClicked
                                                      ? Colors.transparent
                                                      : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _isProgramButtonClicked =
                                                        true;
                                                    _isReportButtonClicked =
                                                        false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProgramPage(
                                                        pid: widget.pid,
                                                      ),
                                                    ),
                                                  ).then((value) {
                                                    setState(() {
                                                      _isProgramButtonClicked =
                                                          false;
                                                    });
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _isProgramButtonClicked
                                                            ? Colors.blueGrey
                                                            : const Color(
                                                                0xFF186257),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: const ListTile(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.hail_outlined,
                                                          color: Colors.white,
                                                          size: 40,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Programs',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            height:
                                                15), // Add spacing between the buttons
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Material(
                                              elevation: _isReportButtonClicked
                                                  ? 0
                                                  : 5,
                                              shadowColor:
                                                  _isReportButtonClicked
                                                      ? Colors.transparent
                                                      : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _isReportButtonClicked =
                                                        true;
                                                    _isProgramButtonClicked =
                                                        false;
                                                  });
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportsHistory(
                                                        pid: widget.pid,
                                                      ),
                                                    ),
                                                  ).then((value) {
                                                    setState(() {
                                                      _isReportButtonClicked =
                                                          false;
                                                    });
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        _isReportButtonClicked
                                                            ? Colors.blueGrey
                                                            : const Color(
                                                                0xFF186257),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: const ListTile(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                    title: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.article,
                                                          color: Colors.white,
                                                          size: 35,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Reports',
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
              ),
            ),
    );
  }
}
