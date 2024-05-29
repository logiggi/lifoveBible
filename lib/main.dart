import 'package:flutter/material.dart';
import 'multi.dart'; // Import the MultiVersionPage widget
import 'single.dart'; // Assuming your original MyHomePage is renamed to SingleVersionPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SingleVersionPage(),
        '/multi_version': (context) => const MultiVersionPage(),
      },
    );
  }
}
