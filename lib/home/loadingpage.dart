import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        // Display a spinning circle with a custom color
        child: SpinKitFadingCircle(color: Color(0xFF186257)),
      ),
    );
  }
}
