import 'package:flutter/material.dart';
import 'package:flutter_application_1/ReportDetails.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/pickProgram.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';

class ReportsHistory extends StatefulWidget {
  final String pid;

  const ReportsHistory({Key? key, required this.pid}) : super(key: key);

  @override
  State<ReportsHistory> createState() => _ReportsHistoryState();
}

class _ReportsHistoryState extends State<ReportsHistory> {
  bool isButtonClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            isButtonClicked = true;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => pickProgram(
                pid: widget.pid,
              ),
            ),
          ).then((value) {
            setState(() {
              isButtonClicked = false;
            });
          });
        },
        backgroundColor:
            isButtonClicked ? Colors.grey : const Color(0xFF186257),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        icon: const Icon(Icons.add),
        label: const Text('Add report'),
      ),
      backgroundColor: const Color(0xFF186257),
      //bottomNavigationBar: const NavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  height: 4000,
                  color: Colors.grey[100],
                  child: Scaffold(
                    backgroundColor: Colors.grey[100],
                    body: Column(
                      children: [
                        const Text(
                          'History of generated reports',
                          style: TextStyle(
                            fontFamily: 'Merriweather',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        StreamBuilder<List<Report>>(
                          stream: FirestoreService()
                              .streamPatientReports(widget.pid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const LoadingPage();
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No reports found.'));
                            }

                            List<Report> reportList = snapshot.data!;

                            // Your code to display the report list
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: reportList.length,
                                itemBuilder: (context, index) {
                                  Report report = reportList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ReportDetails(
                                            pid: report.ProgramID,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      child: ListTile(
                                        leading: Image.asset(
                                          'assets/images/barchart.png',
                                          width: 50,
                                          height: 50,
                                        ),
                                        title: Text(
                                          'Report',
                                        ),
                                        subtitle: Text(
                                          'For program: ${report.ProgramID}',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      ],
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
