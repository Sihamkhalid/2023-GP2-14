import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/ViewType.dart';
import 'package:flutter_application_1/ViewType2.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
// import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/services/firestore.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share_plus/esys_flutter_share_plus.dart'
    as esysShare;
import 'package:open_file/open_file.dart';    

class ReportDetails extends StatefulWidget {
  final String pid;
  ReportDetails({super.key, required this.pid});

  @override
  State<ReportDetails> createState() => _ReportDetailsState();
}

int _currentWeekIndex = 0;
late TabController _tabController;
int _currentIndex = 0;

@override
void initState() {
  // _tabController = TabController(length: 2, vsync: this);
  _tabController.addListener(() {});
}



class _ReportDetailsState extends State<ReportDetails>
    with TickerProviderStateMixin {
  Future<void> _generateAndSharePDF(Report report) async {
    // Generate PDF content

    final pw.Document pdf = await _generatePDF(report);

    // Save PDF to device
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/report_details.pdf';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());

    // Share PDF
    final Uint8List bytes = File(path).readAsBytesSync();
    await esysShare.Share.file(
      'Report Details PDF',
      'Report.pdf',
      bytes,
      'application/pdf',
      text: 'Share Report Details PDF',
    );
  }


Future<void> _generateAndPrintPDF(Report report) async {
  // Generate PDF content
  final pw.Document pdf = await _generatePDF(report);

  // Save PDF to device
  final Directory directory = await getApplicationDocumentsDirectory();
  final String path = '${directory.path}/report_details.pdf';
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());

  // Share PDF
  final Uint8List bytes = File(path).readAsBytesSync();
  await esysShare.Share.file(
    'Report Details PDF',
    'Report.pdf',
    bytes,
    'application/pdf',
    text: 'Share Report Details PDF',
  );

  // Open file explorer to navigate to the folder
  await OpenFile.open(path); // Opens the directory where the file is saved
}

Future<pw.Document> _generatePDF(Report report) async {
  final pw.Document pdf = pw.Document();
  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 20), // Adding space at the top
          pw.Center(
            child: pw.Text(
              'Report',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 24,
                color: PdfColors.blue,
              ),
            ),
          ),
          pw.SizedBox(height: 30), // Adding space between the title and the details
          // Patient Number
          pw.Text(
            'Patient Number: ${report.PatientNumber}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10), // Adding space between details
          // Program ID
          pw.Text(
            'Program ID: ${report.ProgramID}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 10), // Adding space between details
          // Overall Performance
          pw.Text(
            'Overall performance: ${report.OverallPerformance}%',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              color: PdfColors.black,
            ),
          ),
          pw.SizedBox(height: 20),

          // Generate and add the pie chart for overall performance
          _generateOverallPerformancePieChart(report.OverallPerformance),

          // Adding space between overall performance and tables
          pw.SizedBox(height: 20),

 // Months
    for (int monthIndex = 0; monthIndex < report.monthsPercentages.length; monthIndex++)
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // Align content to the left
        children: [
          pw.SizedBox(height: 10), // Adding space between months and tables
          pw.Text('Month ${monthIndex + 1}: ', 
          
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 18, // Increase font size for month headers
              color: PdfColors.green600, // Change color of month headers
            ),
          ), // Month header
             pw.SizedBox(height: 5),
          pw.Table.fromTextArray(
            border: null,
            headers: ['Activity', 'Percentage'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), // Make headers bold
            data: List<List<String>>.generate(
             report.monthsPercentages[monthIndex].R_activity.length,
          (activityIndex) {
            return [
              report.monthsPercentages[monthIndex].R_activity[activityIndex].activityName,
              '${report.monthsPercentages[monthIndex].R_activity[activityIndex].percentage.toString()}%',
            ];
          },
            ),
            cellStyle: pw.TextStyle(fontSize: 14), // Adjust font size for cells
            cellPadding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
            },
          ),
        ],
      ),
    // Adding space between details and tables
    pw.SizedBox(height: 10),

    // Weeks
    for (int weekIndex = 0; weekIndex < report.weeksPercentages.length; weekIndex++) 
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // Align content to the left
        children: [
          pw.SizedBox(height: 10), // Adding space between weeks and tables
          pw.Text('Week ${weekIndex + 1}:', 
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 18, // Increase font size for week headers
              color: PdfColors.green600, // Change color of week headers
            ),
          ),
                pw.SizedBox(height: 5), // Week header
          pw.Table.fromTextArray(
            border: null,
            headers: ['Activity', 'Percentage'],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), // Make headers bold
            data: List<List<String>>.generate(
               report.weeksPercentages[weekIndex].R_activity.length,
          (activityIndex) {
            return [
              report.weeksPercentages[weekIndex].R_activity[activityIndex].activityName,
              '${report.weeksPercentages[weekIndex].R_activity[activityIndex].percentage.toString()}%',
            ];
          },
            ),
            cellStyle: pw.TextStyle(fontSize: 14), // Adjust font size for cells
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

pw.Widget _generateOverallPerformancePieChart(double overallPerformance) {
  // Calculate the angle for the overall performance
  final double performanceAngle = overallPerformance * 3.6;

  return pw.Center(
    child: pw.Stack(
      alignment: pw.Alignment.center,
      children: [
        // Pie chart background
        pw.Container(
          width: 200,
          height: 200,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            color: PdfColors.grey300,
          ),
        ),
        // Pie chart segment for overall performance
        pw.Transform.rotate(
          angle: -performanceAngle * (3.14 / 180), // Convert degrees to radians
          child: pw.Container(
            width: 100,
            height: 200,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: PdfColors.blue,
            ),
          ),
        ),
        // Optional: Display text in the center of the pie chart
        pw.Text(
          '$overallPerformance%',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      ],
    ),
  );
}

  // late int _currentIndex = 0;
  late ScrollController _scrollController = ScrollController();
  // var numOfCards = 0.0;
  late ScrollController _listViewScrollController;
  void scrollToIndex(int index) {
    _listViewScrollController.animateTo(
      index * 400.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      backgroundColor: Color(0xFF186257),
    //  bottomNavigationBar: NavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<Report>(
            stream: FirestoreService().streamReport(widget.pid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingPage();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                Report report = snapshot.data!;
                
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  buildAppBar(),
              
                  // Main content
                  buildMainContent(tabController),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget buildAppBar() {
    return StreamBuilder<Report>(
      stream: FirestoreService().streamReport(widget.pid),
      builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingPage();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                Report report = snapshot.data!;
        return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 25,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      size: 25,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await _generateAndSharePDF(report);
                    },
                  ),
                   IconButton(
                icon: Icon(
                  Icons.print,
                  size: 25,
                  color: Colors.white,
                ),
                onPressed: () async {
                 await  _generateAndPrintPDF(report);
                },
              ),
                ],
              ),
             
        
          ],
        );
      }
    );
    
  }

  Widget buildMainContent(TabController tabController) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: EdgeInsets.all(27),
        height: 1000,
        color: Color.fromARGB(255, 255, 255, 255),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Report Details Title
              buildReportDetailsTitle(),

              // Tab Bar
              buildTabBar(tabController),

              // Tab Bar View
              buildTabBarView(tabController),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReportDetailsTitle() {
    return StreamBuilder<Report>(
      stream: FirestoreService().streamReport(widget.pid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingPage();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                Report report = snapshot.data!;

        return Row(
          children: [
            SizedBox(width: 160),
            Text(
              'Report Details',
              style: TextStyle(
                fontFamily: 'Merriweather',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
       
        
            // IconButton(
            //   onPressed: _viewPdf,
            //   icon: Icon(Icons.print,
            //       color: Colors.black,
            //       size: 30), // Set the color of the icon to black
            // ),
          ],
        );
      }
    );
  }

  Widget buildTabBar(TabController tabController) {
    return TabBar(
      controller: tabController,
      tabs: const [
        Tab(text: 'Weekly'),
        Tab(text: 'Monthly'),
      ],
      labelColor: const Color(0xFF186257),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      indicatorColor: Colors.black,
    );
  }

  Widget buildTabBarView(TabController tabController) {
    return SizedBox(
      width: double.maxFinite,
      height: 3500,
      child: TabBarView(
        controller: tabController,
        children: [
          // Tab: Weekly
          buildWeeklyTabContent(),

          // Tab: Monthly
          buildMonthlyTabContent(),
        ],
      ),
    );
  }

  Widget buildWeeklyTabContent() {
    // Inside your widget
    var viewTypeProvider = Provider.of<ViewTypeProvider>(context);
    // ViewType currentViewType = viewTypeProvider.viewType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryResultsWidgetWeek(),
        SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                const Text(
                  'Patient Performance',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 21,
                  ),
                ),
                const SizedBox(width: 130),
                Padding(
                  padding: const EdgeInsets.all(.2),
                  child: LiteRollingSwitch(
                    textOn: "Chart",
                    textOff: "Text",
                    onChanged: (value) {
                      viewTypeProvider.toggleView();
                    },
                    value: viewTypeProvider.viewType == ViewType.chart,
                    iconOn: Icons.bar_chart,
                    iconOff: Icons.text_fields,
                    colorOn: const Color(0xFF1E786B),
                    colorOff: const Color(0xFF1E786B),
                    textOffColor: const Color.fromARGB(255, 255, 255, 255),
                    textOnColor: const Color.fromARGB(255, 255, 255, 255),
                    textSize: 18,
                    animationDuration: Duration(milliseconds: 200),
                    onTap: () {}, // Empty callback for onTap
                    onDoubleTap: () {}, // Empty callback for onDoubleTap
                    onSwipe: () {}, // Empty callback for onSwipe
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 7,
            ),
            StreamBuilder<Report>(
                stream: FirestoreService().streamReport(widget.pid),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const LoadingPage();
                  // }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                          'Error: Unable to fetch report data due to an error: ${snapshot.error}'),
                    );
                  }
                  Report report = snapshot.data!;
                  ViewType currentViewType = viewTypeProvider.viewType;
                  if (report.weeksPercentages.isEmpty) {
                    return Center(
                      child: Text('Error: No weekly data available'),
                    );
                  }
                  var numOfCards = report.weeksPercentages.length;

                  return SizedBox(
                    height: 500, // Adjust the height of the cards as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: numOfCards,
                      itemBuilder: (BuildContext context, int index) {
                        var weeksPercentages = report.weeksPercentages[index];
                        return Container(
                          width: 420, // Adjust the width of the cards as needed
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(children: [
                                SizedBox(
                                  width: 170,
                                ),
                                Text(
                                  'Week ${index + 1}',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ]),
                              Consumer<ViewTypeProvider>(
                                builder: (context, viewTypeProvider, _) {
                                  return viewTypeProvider.viewType ==
                                          ViewType.chart
                                      ? Padding(
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: barChartWeek(
                                                  widget.pid, index)),
                                        )
                                      : Container(
                                          width: 500,
                                          height: 420,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 10),
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: List.generate(
                                                    report
                                                        .weeksPercentages[index]
                                                        .R_activity
                                                        .length, //here activities length
                                                    (index) => Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15,
                                                          horizontal: 15),
                                                      decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255)
                                                                .withOpacity(
                                                                    0.5),
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 40,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255)
                                                                  .withOpacity(
                                                                      0.3),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/previousProgram.png',
                                                                // width: 30,
                                                                // height: 30,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 20),
                                                          Expanded(
                                                            child: Text(
                                                              '${weeksPercentages.R_activity[index].activityName}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Merriweather',
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            '${weeksPercentages.R_activity[index].percentage}%',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Merriweather',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: weeksPercentages
                                                                          .R_activity[
                                                                              index]
                                                                          .percentage >=
                                                                      50
                                                                  ? Colors
                                                                      .green // If percentage is 50% or above, color green
                                                                  : Colors
                                                                      .red, // If percentage is below 50%, color red
                                                            ),
                                                          ),
                                                        ],
                                                      ),
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
                        );
                      },
                    ),
                  );
                }),
          ],
        ),
      ],
    );
  }

  Widget SummaryResultsWidgetWeek() {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SingleChildScrollView(
          child: StreamBuilder<Report>(
            stream: FirestoreService().streamReport(widget.pid),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const LoadingPage();
              // }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // bool _isLoading = false;
              String _error = '';
              // if (_isLoading) {
              //   return const LoadingPage();
              // } else
              if (_error.isNotEmpty) {
                return Center(
                  child: Text('Error: $_error'),
                );
              } else {
                var report = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Summary Results',
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 19,
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 160,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 9, 0),
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color.fromARGB(
                                                            255, 250, 207, 89)
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/images/icons8-time-32.png',
                                                      width: 230,
                                                      height: 230,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 10, 0),
                                                      child: Text(
                                                        '${report.OverallPerformance}%',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Average',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Merriweather',
                                                        fontSize: 15,
                                                        color: Color.fromARGB(
                                                            255, 75, 116, 133),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                        Container(
                                          width: 160,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 9, 0),
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color.fromARGB(
                                                            1, 95, 253, 240)
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/images/icons8-what-i-do-36.png',
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 55, 0),
                                                      child: Text(
                                                        '${report.NumberOfActivities}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Activities',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Merriweather',
                                                        fontSize: 15,
                                                        color: Color.fromARGB(
                                                            255, 75, 116, 133),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Container(
                                width: 160,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 9, 0),
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                                  255, 99, 193, 248)
                                              .withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/icons8-repeat-34.png',
                                            width: 230,
                                            height: 230,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 25, 0),
                                            child: Text(
                                              '${report.NumberOfIterations}',
                                              style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Iterations',
                                            style: TextStyle(
                                              fontFamily: 'Merriweather',
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 75, 116, 133),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 25),
                              Container(
                                width: 160,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 9, 0),
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                                  255, 252, 171, 231)
                                              .withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/icons8-schedule-36.png',
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 42, 0),
                                            child: Text(
                                              '${report.NumberOfWeeks}',
                                              style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Weeks',
                                            style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 75, 116, 133)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget barChartWeek(String pid, int index) {
    late List<BarChartGroupData> rawBarGroups;
    late List<BarChartGroupData> showingBarGroups;
    late Report? _report;
    Map<String, int> activityNameToIndex = {};

    void initState() {
      rawBarGroups = [];
      showingBarGroups = rawBarGroups;
    }

    SideTitles _bottomTitles(Report report, int index) {
      return SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: 2,
        getTitlesWidget: (value, meta) {
          List<String> activityNames = report.weeksPercentages[index].R_activity
              .map((activity) => activity.activityName)
              .toList();

          int A_index = value.toInt();
          if (A_index >= 0 && A_index < activityNames.length) {
            return Text(activityNames[A_index]);
          }
          return Text('');
        },
      );
    }

    BarChartGroupData makeGroupData(
      R_Activity activity,
      int index,
      Map<String, int> activityNameToIndex,
    ) {
      if (!activityNameToIndex.containsKey(activity.activityName)) {
        activityNameToIndex[activity.activityName] = activityNameToIndex.length;
      }

      int xValue = activityNameToIndex[activity.activityName]!;
      double barHeight = activity.percentage;

      return BarChartGroupData(
        x: xValue,
        barRods: [
          BarChartRodData(
            fromY: 0,
            color: Colors.blue,
            width: 20,
            toY: barHeight,
          ),
        ],
      );
    }

    return StreamBuilder<Report>(
      stream: FirestoreService().streamReport(pid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _report = snapshot.data;
          if (_report == null) return Container();

          var weeksPercentages = _report!.weeksPercentages;
          var selectedWeeksPercentages = weeksPercentages[index];

          rawBarGroups = selectedWeeksPercentages.R_activity.asMap()
              .entries
              .map((entry) =>
                  makeGroupData(entry.value, entry.key, activityNameToIndex))
              .toList();

          showingBarGroups = rawBarGroups;

          return AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        maxY: 100,
                        minY: 0,
                        barGroups: showingBarGroups,
                        borderData: FlBorderData(border: const Border()),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          drawHorizontalLine: true,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: _bottomTitles(_report!, index),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildMonthlyTabContent() {
    // Inside your widget
    ViewTypeProvider2 viewTypeProvider2 =
        Provider.of<ViewTypeProvider2>(context, listen: false);

    // ViewType currentViewType = ViewTypeProvider2.viewType;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryResultsWidgetMonth(),
        SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 12,
            ),
            Row(
              children: [
                const Text(
                  'Patient Performance',
                  style: TextStyle(
                    fontFamily: 'Merriweather',
                    fontSize: 21,
                  ),
                ),
                const SizedBox(width: 130),
                Padding(
                  padding: const EdgeInsets.all(.1),
                  child: LiteRollingSwitch(
                    textOn: "Chart",
                    textOff: "Text",
                    onChanged: (value) {
                      viewTypeProvider2.toggleView2();
                    },
                    value: viewTypeProvider2.viewType2 == ViewType2.chart,
                    iconOn: Icons.bar_chart,
                    iconOff: Icons.text_fields,
                    colorOn: const Color(0xFF1E786B),
                    colorOff: const Color(0xFF1E786B),
                    textOffColor: const Color.fromARGB(255, 255, 255, 255),
                    textOnColor: const Color.fromARGB(255, 255, 255, 255),
                    textSize: 17,
                    animationDuration: Duration(milliseconds: 200),
                    onTap: () {}, // Empty callback for onTap
                    onDoubleTap: () {}, // Empty callback for onDoubleTap
                    onSwipe: () {}, // Empty callback for onSwipe
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 7,
            ),
            StreamBuilder<Report>(
                stream: FirestoreService().streamReport(widget.pid),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const LoadingPage();
                  // }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Text(
                          'Error: Unable to fetch report data due to an error: ${snapshot.error}'),
                    );
                  }
                  Report report = snapshot.data!;

                  if (report.monthsPercentages.isEmpty) {
                    return Center(
                      child: Text('Error: No weekly data available'),
                    );
                  }
                  var numOfCards = report.monthsPercentages.length;

                  return SizedBox(
                    height: 500, // Adjust the height of the cards as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: numOfCards,
                      itemBuilder: (BuildContext context, int index) {
                        var monthsPercentages = report.monthsPercentages[index];
                        return Container(
                          width: 420, // Adjust the width of the cards as needed
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(children: [
                                SizedBox(
                                  width: 170,
                                ),
                                Text(
                                  'Month ${index + 1}',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ]),
                              Consumer<ViewTypeProvider2>(
                                builder: (context, viewTypeProvider2, _) {
                                  return viewTypeProvider2.viewType2 ==
                                          ViewType2.chart
                                      ? Padding(
                                          padding: EdgeInsets.all(0),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 3,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: barChartMonth(
                                                  widget.pid, index)),
                                        )
                                      : Container(
                                          width: 500,
                                          height: 420,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: List.generate(
                                                report
                                                    .monthsPercentages[index]
                                                    .R_activity
                                                    .length, // here activities length
                                                (index) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 10,
                                                    horizontal: 15,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: const Color
                                                                .fromARGB(255,
                                                                255, 255, 255)
                                                            .withOpacity(0.5),
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: const Color
                                                                  .fromARGB(255,
                                                                  255, 255, 255)
                                                              .withOpacity(0.3),
                                                        ),
                                                        child: Center(
                                                          child: Image.asset(
                                                            'assets/images/previousProgram.png',
                                                            // width: 24,
                                                            // height: 24,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 20),
                                                      Expanded(
                                                        child: Text(
                                                          '${monthsPercentages.R_activity[index].activityName}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Merriweather',
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${monthsPercentages.R_activity[index].percentage}%',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: monthsPercentages
                                                                      .R_activity[
                                                                          index]
                                                                      .percentage >=
                                                                  50
                                                              ? Colors
                                                                  .green // If percentage is 50% or above, color green
                                                              : Colors
                                                                  .red, // If percentage is below 50%, color red
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),
          ],
        ),
      ],
    );
  }

  Widget SummaryResultsWidgetMonth() {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SingleChildScrollView(
          child: StreamBuilder<Report>(
            stream: FirestoreService().streamReport(widget.pid),
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const LoadingPage();
              // }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // bool _isLoading = false;
              String _error = '';
              // if (_isLoading) {
              //   return const LoadingPage();
              // }
              // else
              if (_error.isNotEmpty) {
                return Center(
                  child: Text('Error: $_error'),
                );
              } else {
                var report = snapshot.data!;
                double numberofmonth = report.NumberOfWeeks / 4;
                int roundedNumberofmonth = numberofmonth.ceil();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Summary Results',
                      style: TextStyle(
                        fontFamily: 'Merriweather',
                        fontSize: 19,
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 160,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 9, 0),
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color.fromARGB(
                                                            255, 250, 207, 89)
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/images/icons8-time-32.png',
                                                      width: 230,
                                                      height: 230,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 10, 0),
                                                      child: Text(
                                                        '${report.OverallPerformance}%',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Average',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Merriweather',
                                                        fontSize: 15,
                                                        color: Color.fromARGB(
                                                            255, 75, 116, 133),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                        Container(
                                          width: 160,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.3),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 9, 0),
                                                child: Container(
                                                  width: 55,
                                                  height: 55,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color.fromARGB(
                                                            1, 95, 253, 240)
                                                        .withOpacity(0.3),
                                                  ),
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/images/icons8-what-i-do-36.png',
                                                      width: 80,
                                                      height: 80,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 20),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              0, 0, 55, 0),
                                                      child: Text(
                                                        '${report.NumberOfActivities}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Merriweather',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Activities',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Merriweather',
                                                        fontSize: 15,
                                                        color: Color.fromARGB(
                                                            255, 75, 116, 133),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Container(
                                width: 160,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 9, 0),
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                                  255, 99, 193, 248)
                                              .withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/icons8-repeat-34.png',
                                            width: 230,
                                            height: 230,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 25, 0),
                                            child: Text(
                                              '${report.NumberOfIterations}',
                                              style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Iterations',
                                            style: TextStyle(
                                              fontFamily: 'Merriweather',
                                              fontSize: 15,
                                              color: Color.fromARGB(
                                                  255, 75, 116, 133),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 25),
                              Container(
                                width: 160,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 9, 0),
                                      child: Container(
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color.fromARGB(
                                                  255, 252, 171, 231)
                                              .withOpacity(0.3),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            'assets/images/icons8-schedule-36.png',
                                            width: 80,
                                            height: 80,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 0, 42, 0),
                                            child: Text(
                                              '${roundedNumberofmonth}',
                                              style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Months',
                                            style: TextStyle(
                                                fontFamily: 'Merriweather',
                                                fontSize: 15,
                                                color: Color.fromARGB(
                                                    255, 75, 116, 133)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget barChartMonth(String pid, int index) {
    late List<BarChartGroupData> rawBarGroups;
    late List<BarChartGroupData> showingBarGroups;
    late Report? _report;
    Map<String, int> activityNameToIndex = {};

    void initState() {
      rawBarGroups = [];
      showingBarGroups = rawBarGroups;
    }

    SideTitles _bottomTitles(Report report, int index) {
      return SideTitles(
        showTitles: true,
        reservedSize: 22,
        interval: 2,
        getTitlesWidget: (value, meta) {
          List<String> activityNames = report
              .monthsPercentages[index].R_activity
              .map((activity) => activity.activityName)
              .toList();

          int A_index = value.toInt();
          if (A_index >= 0 && A_index < activityNames.length) {
            return Text(activityNames[A_index]);
          }
          return Text('');
        },
      );
    }

    BarChartGroupData makeGroupData(
      R_Activity activity,
      int index,
      Map<String, int> activityNameToIndex,
    ) {
      if (!activityNameToIndex.containsKey(activity.activityName)) {
        activityNameToIndex[activity.activityName] = activityNameToIndex.length;
      }

      int xValue = activityNameToIndex[activity.activityName]!;
      double barHeight = activity.percentage;

      return BarChartGroupData(
        x: xValue,
        barRods: [
          BarChartRodData(
            fromY: 0,
            color: Colors.blue,
            width: 20,
            toY: barHeight,
          ),
        ],
      );
    }

    return StreamBuilder<Report>(
      stream: FirestoreService().streamReport(pid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          _report = snapshot.data;
          if (_report == null) return Container();

          var monthsPercentages = _report!.monthsPercentages;
          var selectedmonthsPercentages = monthsPercentages[index];

          rawBarGroups = selectedmonthsPercentages.R_activity.asMap()
              .entries
              .map((entry) =>
                  makeGroupData(entry.value, entry.key, activityNameToIndex))
              .toList();

          showingBarGroups = rawBarGroups;

          return AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        maxY: 100,
                        minY: 0,
                        barGroups: showingBarGroups,
                        borderData: FlBorderData(border: const Border()),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          drawHorizontalLine: true,
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: _bottomTitles(_report!, index),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
