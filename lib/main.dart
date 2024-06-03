import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'multi.dart';
// import 'single.dart';
import 'select.dart';
import 'setting.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => SettingProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingProvider>(builder: (context, settings, child) {
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
          '/setting': (context) => const SettingPage(),
        },
      );
    });
  }
}
