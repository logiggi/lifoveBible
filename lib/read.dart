import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class readPage extends StatefulWidget {
  final String bibleVersion;

  const readPage({super.key, required this.bibleVersion});

  @override
  _readPage createState() => _readPage();
}

class _readPage extends State<readPage> {
  String readCount(String book) {
    int ret = 0;
    for(int i=0; i<reads.length; i++) {
      if(reads[i].getVersion() == widget.bibleVersion) {
        int len = reads[i].getLength(book) ?? 0;
        for(int j=0; j<len; j++) {
          bool val = reads[i].getRead(book, j) ?? false;
          ret += (val ? 1: 0);
        }
      }
    }
    return ret.toString();
  }


  @override
  Widget build(BuildContext context) {
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
        title: Text('Read status'),
      ),
      body: ListView.builder(
        itemCount: bookChapters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]),
            trailing: Text(readCount(books[index]) + ' / ' + chapters[index].toString())

          );
        },
      ),
    );
  }
}
