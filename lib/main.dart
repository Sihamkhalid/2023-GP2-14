import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ReportDetails.dart';
import 'package:flutter_application_1/ViewType2.dart';
import 'package:flutter_application_1/routes.dart'; // Importing routes.dart file
import 'package:flutter_application_1/ViewType.dart'; // Import the ViewTypeProvider
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //name: "theraSense",
      options: const FirebaseOptions(
    apiKey: "AIzaSyCQCd9MmNZDhYQsQ6HX5jbmSewa0QfDM7o",
    appId: "1:1006673537036:android:c4d2575e80e2d5d0606629",
    messagingSenderId: "1006673537036",
    projectId: "therasense-8f8c3",
    storageBucket: "gs://therasense-8f8c3.appspot.com",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Use MultiProvider to manage multiple providers
      providers: [
        ChangeNotifierProvider(
            create: (_) => ViewTypeProvider()), // First provider
        ChangeNotifierProvider(
            create: (_) => ViewTypeProvider2()), // Second provider
      ],
      child: MaterialApp(
        routes: appRoutes,
      ),
    );
  }
}
