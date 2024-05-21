import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({super.key});

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            File? file = await _pickFile();
            if (file != null) {
              setState(() {
                _selectedFile = file;
              });
            }
          },
          child: const Text('Select File'),
        ),
        if (_selectedFile != null)
          Column(
            children: [
              const SizedBox(height: 16),
              Text('Selected File: ${_selectedFile!.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _uploadFile(_selectedFile!);
                },
                child: const Text('Upload File'),
              ),
            ],
          ),
      ],
    );
  }

  Future<File?> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        return file;
      } else {
        // User canceled the file picking
        return null;
      }
    } catch (e) {
      print("Error picking file: $e");
      return null;
    }
  }

  Future<void> _uploadFile(File file) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = 'uploads/$fileName';

    try {
      firebase_storage.Reference ref =
          firebase_storage.FirebaseStorage.instance.ref(filePath);
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();

      // Use the downloadURL as needed (e.g., store it in Firestore)
      print('File uploaded successfully. Download URL: $downloadURL');
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
