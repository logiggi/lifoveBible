import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lifovebible/read.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class readIndexPage extends StatefulWidget {
  const readIndexPage({super.key});

  @override
  _readIndexPage createState() => _readIndexPage();
}

class _readIndexPage extends State<readIndexPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> bibleVersions = fileUrls.keys.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)
        ),
        title: Text('Bible reading chart'),
      ),
      body: ListView.builder(
        itemCount: bibleVersions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(bibleVersions[index]),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => readPage()),
            ),
          );
        },
      ),
    );
  }
}

// Example of a new page for a specific Bible version
class BibleVersionPage extends StatelessWidget {
  final String version;

  const BibleVersionPage({required this.version});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(version),
      ),
      body: Center(
        child: Text('Content for $version'),
      ),
    );
  }
}
