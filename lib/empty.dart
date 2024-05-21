import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/loadingpage.dart';
import 'package:flutter_application_1/services/models.dart';
import 'package:flutter_application_1/shared/nav_bar.dart';
import 'package:intl/intl.dart';
import '../services/firestore.dart';

class Empty extends StatefulWidget {
  const Empty({super.key});

  @override
  State<Empty> createState() => _EmptyState();
}

class _EmptyState extends State<Empty> {
  File? _selectedFile;

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadPDF() async {
    if (_selectedFile != null) {
      await FirestoreService().uploadFile(_selectedFile!);
      // Handle success or error
    } else {
      // Show an error message that no file is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: const NavBar(),
        // body: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     ElevatedButton(
        //       onPressed: _pickPDF,
        //       child: Text('Select PDF'),
        //     ),
        //     SizedBox(height: 16),
        //     if (_selectedFile != null)
        //       Text('Selected PDF: ${_selectedFile!.path}'),
        //     SizedBox(height: 16),
        //     ElevatedButton(
        //       onPressed: _uploadPDF,
        //       child: Text('Upload PDF'),
        //     ),
        //   ],
        // ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<Program>(
                stream:
                    FirestoreService().streamProgram('4ATylTUU75XEo7hH6PZF'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingPage();
                  }
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  Program program = snapshot.data!;
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('yyyy-MM-dd')
                          .format(program.startDate.toDate())),
                      Text('${program.numofAct}'),
                      Text(program.activities.first.activityName),
                      Text('${program.activities.first.frequency}')
                    ],
                  ));
                }),
            StreamBuilder<List<Program>>(
                stream: FirestoreService().streamPatientPrograms('37637'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingPage();
                  }
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<Program> programs = snapshot.data!;
                  return Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('yyyy-MM-dd')
                          .format(programs[0].startDate.toDate())),
                      Text('${programs[0].numofAct}'),
                      Text(programs[0].activities.first.activityName),
                      Text('${programs[0].activities.first.frequency}')
                    ],
                  ));
                }),
          ],
        ));
  }
}
