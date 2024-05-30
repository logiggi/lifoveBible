import 'package:flutter/material.dart';
import 'multi.dart';
// import 'single.dart';
import 'select.dart';

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
        // '/': (context) => const SingleVersionPage(),
        '/': (context) => const VersionSelectionPage(),
        '/multi_version': (context) => const MultiVersionPage(),
      },
    );
  }
}
