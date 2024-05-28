import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String fileUrl = 'https://lifovebible.github.io/data/kornkrv.lfa';
  final String fileName = 'kornkrv.lfa';
  List<String> files = [];
  int currentIndex = 0;
  String fileContent = '';

  Future<void> fetchFiles() async {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = path.join(dir.path, fileName);
    
    String zipFilePath = filePath.replaceAll('.lfa', '.zip');

    if (await Permission.storage.request().isGranted) {
      try {
        // 파일 다운로드
        await Dio().download(fileUrl, filePath);
        // .lfa 파일을 .zip으로 변경
        File(filePath).renameSync(zipFilePath);
        // .zip 파일 압축 해제
        var bytes = File(zipFilePath).readAsBytesSync();
        var archive = ZipDecoder().decodeBytes(bytes);
        var extractedFiles = <String>[];
        for (var file in archive) {
          var filePath = path.join(dir.path, file.name);
          if (file.isFile) {
            var outFile = File(filePath);
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(file.content as List<int>);
            String newFilePath = filePath.replaceAll('.lfb', '.txt');
            outFile.renameSync(newFilePath);
            extractedFiles.add(newFilePath);
          } else {
            Directory(filePath).create(recursive: true);
          }
        }
        setState(() {
          files = extractedFiles;
          currentIndex = 0;
          if (files.isNotEmpty) {
            fileContent = File(files[currentIndex]).readAsStringSync();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Files fetched and processed')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetch failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  void showNextFile() {
    setState(() {
      if (currentIndex < files.length - 1) {
        currentIndex++;
        fileContent = File(files[currentIndex]).readAsStringSync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No more files to display')),
        );
      }
    });
  }

  void showPreviousFile() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        fileContent = File(files[currentIndex]).readAsStringSync();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This is the first file')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('File Download and Process Example'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: fetchFiles,
            child: Text('Fetch Files'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: files.isNotEmpty
                ? SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text(fileContent),
            )
                : Center(child: Text('No content to display')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: showPreviousFile,
                child: Text('Previous'),
              ),
              ElevatedButton(
                onPressed: showNextFile,
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
