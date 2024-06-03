import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class VersionSelectionPage extends StatefulWidget {
  const VersionSelectionPage({Key? key}) : super(key: key);

  @override
  _VersionSelectionPageState createState() => _VersionSelectionPageState();
}

class _VersionSelectionPageState extends State<VersionSelectionPage> {
  String? selectedBook;
  int? selectedChapter;
  int currentIndex = 0;

  Future<void> fetchFiles(String version) async {
    String fileName = 'kornkrv.lfa';
    if (downloadedVersions.contains(version)) {
      return;
    }
    var dir = await getApplicationDocumentsDirectory();
    String filePath = path.join(dir.path, fileName);
    String zipFilePath = filePath.replaceAll('.lfa', '.zip');

    if (true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading and processing files...'),
            duration: Duration(milliseconds: 300),
          ),
        );
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Downloading Files...'),
              content: LinearProgressIndicator(),
            );
          },
        );

        await Dio().download(fileUrls[version]!, filePath);

        Navigator.of(context).pop();

        File(filePath).renameSync(zipFilePath);

        var bytes = File(zipFilePath).readAsBytesSync();
        var archive = ZipDecoder().decodeBytes(bytes);
        var extractedFiles = <String>[];
        var fileNumberRegex = RegExp(r'\d+');
        for (var file in archive) {
          var filePath = path.join(dir.path, file.name);
          if (file.isFile && fileNumberRegex.hasMatch(file.name)) {
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
          var fileGroups = <String, List<String>>{};
          for (var filePath in extractedFiles) {
            var bookPrefix = filePath.substring(
                filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('_'));
            if (!fileGroups.containsKey(bookPrefix)) {
              fileGroups[bookPrefix] = [];
            }
            fileGroups[bookPrefix]!.add(filePath);
          }

          fileGroups.forEach((bookPrefix, files) {
            files.sort((a, b) {
              int aIndex = int.parse(
                  a.substring(a.lastIndexOf('_') + 1, a.lastIndexOf('.')));
              int bIndex = int.parse(
                  b.substring(b.lastIndexOf('_') + 1, b.lastIndexOf('.')));
              return aIndex.compareTo(bIndex);
            });
          });

          // Sort the keys (book prefixes) according to the desired order
          var sortedBookPrefixes = fileGroups.keys.toList()
            ..sort((a, b) {
              var regex = RegExp(r'\d+');
              var aIndex = int.parse(regex.firstMatch(a)!.group(0)!);
              var bIndex = int.parse(regex.firstMatch(b)!.group(0)!);
              return aIndex.compareTo(bIndex);
            });

          extractedFiles.clear();
          for (var bookPrefix in sortedBookPrefixes) {
            extractedFiles.addAll(fileGroups[bookPrefix]!);
          }
          filesMap[version] = extractedFiles;
          currentIndex = 0;
          if (extractedFiles.isNotEmpty) {
            fileContents[version] =
                File(extractedFiles[currentIndex]).readAsStringSync();
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Files fetched and processed'),
            duration: Duration(milliseconds: 300),
          ),
        );
        downloadedVersions.add(version);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fetch failed: $e'),
            duration: Duration(milliseconds: 2000),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission denied'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  void loadSelectedBookAndChapter() {
    if (selectedBook != null && selectedChapter != null) {
      int bookIndex = bookChapters.keys.toList().indexOf(selectedBook!);
      int chapterIndex = selectedChapter! - 1;
      currentIndex = bookIndex + chapterIndex;
      setState(() {
        fileContents.clear();
        for (var version in selectedVersions) {
          if (filesMap.containsKey(version)) {
            fileContents[version] =
                File(filesMap[version]![currentIndex]).readAsStringSync();
          }
        }
      });
    }
  }

  Future<void> handleVersionSelection(String version) async {
    setState(() {
      if (selectedVersions.contains(version)) {
        selectedVersions.remove(version);
      } else {
        selectedVersions.add(version);
      }
    });

    if (selectedVersions.contains(version)) {
      if (downloadedVersions.contains(version)) {
        return;
      }
      await fetchFiles(version);
      loadSelectedBookAndChapter();
      downloadedVersions.add(version);
    }
  }

  void navigateToMultiVersionPage() {
    for (var version in selectedVersions) {
      reads.add(ReadStatus(version));
    }
    Navigator.pushReplacementNamed(context, '/multi_version');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Versions'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Please select at least two versions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: fileUrls.keys.map((String version) {
                return CheckboxListTile(
                  title: Text(version),
                  value: selectedVersions.contains(version),
                  onChanged: (bool? value) {
                    handleVersionSelection(version);
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: navigateToMultiVersionPage,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
