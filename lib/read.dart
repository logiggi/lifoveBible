import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

final List<String> readBible = [];

class readBiblePage extends StatefulWidget {
  const readBiblePage({super.key});

  @override
  _readBiblePage createState() => _readBiblePage();
}

class _readBiblePage extends State<readBiblePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back)
        ),
        title: const Text('Read Items'),
      ),
      body: ListView.builder(
        itemCount: readBible.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(readBible[index]),
          );
        },
      ),
    );
  }
}
