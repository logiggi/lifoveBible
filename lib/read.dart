import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class readPage extends StatefulWidget {
  const readPage({super.key});

  @override
  _readPage createState() => _readPage();
}

class _readPage extends State<readPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> versions = fileUrls.keys.toList();
    final List<String> books = bookChapters.keys.toList();
    final List<int> chapters = bookChapters.values.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)
        ),
        title: Text('bookChapters'),
      ),
      body: ListView.builder(
        itemCount: bookChapters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]),
            trailing: Text(readStatus[versions[index]]![books[index]].toString() + ' ' + chapters[index].toString()),
          );
        },
      ),
    );
  }
}
