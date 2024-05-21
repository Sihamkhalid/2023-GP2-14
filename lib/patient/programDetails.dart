//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/empty.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/patient/EditProgramPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart'
    as esysShare;

class ProgramDetails extends StatefulWidget {
  final String pid;
  const ProgramDetails({Key? key, required this.pid}) : super(key: key);

  @override
  State<ProgramDetails> createState() => _ProgramDetailsState();
}

class _ProgramDetailsState extends State<ProgramDetails> {
  bool DoesNotHaveReport = true;

  @override
  void initState() {
    super.initState();
    _checkReport();
  }

  void _checkReport() {
    FirestoreService().streamReport(widget.pid).listen((report) {
      if (report != null) {
        setState(() {
          DoesNotHaveReport = false;
        });
      }
    });
  }

    Future<void> _generateAndSharePDF(Program program) async {
    // Generate PDF content

    final pw.Document pdf = await _generatePDF(program);

    // Save PDF to device
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/report_details.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Share PDF
    final Uint8List bytes = File(path).readAsBytesSync();
    await esysShare.Share.file(
      'Program Details PDF',
      'Program.pdf',
      bytes,
      'application/pdf',
      text: 'Share program PDF',
    );
  }

  Future<pw.Document> _generatePDF(Program program) async {
    final pw.Document pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
return pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.start,
  children: [
    pw.SizedBox(height: 20),

  pw.Center(
      child: pw.Text(
        'Program',
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 24,
          color: PdfColors.blue, 
        ),
      ),
    ),

    pw.SizedBox(height: 30), 

    // Patient Number
    pw.Text(
      'Patient Number: ${program.patientNum}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 16, 
        color: PdfColors.black,
      ),
    ),

    pw.SizedBox(height: 10),
    // Program ID
    pw.Text(
      'Program ID: ${program.pid}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 16,
        color: PdfColors.black,
      ),
    ),

    pw.SizedBox(height: 10), 

    pw.Text(
      'Start Date: ${DateFormat('yyyy-MM-dd').format(program.startDate.toDate())}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 16, 
        color: PdfColors.black,
      ),
    ),

    pw.Text(
      'End Date: ${DateFormat('yyyy-MM-dd').format(program.endDate.toDate())}',
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 16,
        color: PdfColors.black, 
      ),
    ),

    pw.SizedBox(height: 20),

      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // Align content to the left
        children: [
          pw.SizedBox(height: 10
          ), 
        
         pw.Table.fromTextArray(
  border: null,
  headers: ['Activity', 'Frequency' , 'Days per week:'],
  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16), 
  data: List<List<String>>.generate(
    program.activities.length,
    (activityIndex) {
      return [
         program.activities[activityIndex].activityName,
        '${program.activities[activityIndex].frequency}',
        '${program.activities[activityIndex].TimesPerWeek}',
      ];
    },
  ),
  cellStyle: pw.TextStyle(fontSize: 14),
  cellPadding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
  cellAlignments: {
    0: pw.Alignment.centerLeft,
    1: pw.Alignment.centerLeft,
  },
),


        ],
      ),
    pw.SizedBox(height: 10),
 
  ],
);

      },
    ));
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF186257),
     // bottomNavigationBar: const NavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<Program>(
            stream: FirestoreService().streamProgram(widget.pid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingPage();
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              Program program = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Positioned(
                        top: 20,
                        left: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                size: 25,
                                color: Color(0xFFFFFFFF),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                          icon: Icon(
                            Icons.share,
                            size: 25,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          onPressed: () async {
                            await _generateAndSharePDF(program);
                          },
                        ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 40, 25, 0),
                    child: StreamBuilder<Patient>(
                      stream:
                          FirestoreService().streamPatient(program.patientNum),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LoadingPage();
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        Patient patient = snapshot.data!;
                        var avatar = 'man';

                        switch (patient.gender) {
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
                                patient.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Patient information section
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      height: 1000,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display program information
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  const Text(
                                    'Program Information',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  DoesNotHaveReport
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color:
                                                Color.fromARGB(255, 78, 78, 78),
                                            size: 30,
                                          ),
                                          onPressed: () {
                                           
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPage(program: program),
                                  ),
                                );
                              
                                          },
                                        )
                                      : SizedBox(),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: DataTable(
                                  columnSpacing: 120.0,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Start Date',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'End Date',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    DataRow(
                                      cells: [
                                        DataCell(Text(
                                            '${DateFormat('yyyy-MM-dd').format(program.startDate.toDate())}')),
                                        DataCell(
                                          Center(
                                            child: Text(
                                                '${DateFormat('yyyy-MM-dd').format(program.endDate.toDate())}'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Center(
                                child: DataTable(
                                  columnSpacing: 120.0,
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'Activity',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Days per week',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Frequency',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    for (var activity in program.activities)
                                      DataRow(
                                        cells: [
                                          DataCell(Text(activity.activityName)),
                                            DataCell(Center(child: Text('${activity.TimesPerWeek}'))),
                                          DataCell(
                                            Center(
                                              child:
                                                  Text('${activity.frequency}'),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}