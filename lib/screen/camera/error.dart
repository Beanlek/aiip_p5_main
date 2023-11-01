import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key, required this.errorMessage});

  final String errorMessage;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Something went wrong',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
          body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          const Center(child: Text('Server error')),
          Lottie.asset('assets/error.json')
        ],
      )),
    );
  }
}
