import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/patient/AddProgramPage.dart';
import 'package:flutter_application_1/patient/programDetails.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:intl/intl.dart';

class ProgramPage extends StatefulWidget {
  final String pid;
  const ProgramPage({Key? key, required this.pid}) : super(key: key);

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  bool _isFABClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF186257),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _isFABClicked = true;
          });
          // Navigate to the 'AddProgramPage' screen on button press
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProgramPage(pid: widget.pid),
            ),
          ).then((_) {
            setState(() {
              _isFABClicked = false;
            });
          });
        },
        label: const Text(
          'Add program',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor:
            _isFABClicked ? Colors.blueGrey : const Color(0xFF186257),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(25, 40, 25, 0),
              ),
              StreamBuilder<List<Program>>(
                stream: FirestoreService().streamPatientPrograms(widget.pid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingPage();
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Program> programs = snapshot.data!;
                  programs.sort((a, b) => b.endDate.compareTo(a.endDate));

                  if (programs.isEmpty) {
                    return Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          height: 800,
                          color: Colors.grey[100],
                          child: Scaffold(
                            backgroundColor: Colors.grey[100],
                            body: const Center(
                                child: Text('No Program Added Yet')),
                          ),
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            height: 4000,
                            color: Colors.grey[100],
                            child: Scaffold(
                              backgroundColor: Colors.grey[100],
                              body: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  const Text(
                                    'All programs',
                                    style: TextStyle(
                                      fontFamily: 'Merriweather',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: programs.length,
                                      itemBuilder: (context, index) {
                                        Program program = programs[index];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProgramDetails(
                                                      pid: program.pid,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Material(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                elevation: 5,
                                                shadowColor: Colors
                                                    .grey, // Customize shadow color if needed
                                                child: ListTile(
                                                  leading: Image.asset(
                                                    'images/currentProgram.png',
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                                  title: Text(
                                                    'Program ID: ${index + 1}',
                                                  ),
                                                  subtitle: Text(
                                                      'Ends on ${DateFormat('yyyy-MM-dd').format(program.endDate.toDate())}'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
