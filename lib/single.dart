import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart';

class SingleVersionPage extends StatefulWidget {
  const SingleVersionPage({super.key});

  @override
  _SingleVersionPageState createState() => _SingleVersionPageState();
}

class _SingleVersionPageState extends State<SingleVersionPage> {
  final Set<String> downloadedVersions = {};
  String fileName = 'kornkrv.lfa';
  List<String> files = [];
  int currentIndex = 0;
  String fileContent = '';
  String? selectedVersion;
  String? selectedBook;
  int? selectedChapter;

  Future<void> fetchFiles(String version) async {
    if (downloadedVersions.contains(version)) {
      // Version already downloaded, no need to download again
      return;
    }
    // var status = await Permission.storage.request();
    var dir = await getApplicationDocumentsDirectory();
    String filePath = path.join(dir.path, fileName);
    String zipFilePath = filePath.replaceAll('.lfa', '.zip');

    if (await Permission.storage.request().isGranted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading and processing files...')),
        );
        // 파일 다운로드
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

        // Download file with progress tracking
        await Dio().download(fileUrls[version]!, filePath);

        // Close progress dialog
        Navigator.of(context).pop();
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
            // Group files by book prefixes
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

          // Sort files within each group
          fileGroups.forEach((bookPrefix, files) {
            files.sort((a, b) {
              int aIndex = int.parse(
                  a.substring(a.lastIndexOf('_') + 1, a.lastIndexOf('.')));
              int bIndex = int.parse(
                  b.substring(b.lastIndexOf('_') + 1, b.lastIndexOf('.')));
              return aIndex.compareTo(bIndex);
            });
          });

          // Flatten sorted groups back into extractedFiles list
          extractedFiles.clear();
          for (var files in fileGroups.values) {
            extractedFiles.addAll(files);
          }
          files = extractedFiles;
          currentIndex = 0;
          if (files.isNotEmpty) {
            fileContent = File(files[currentIndex]).readAsStringSync();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files fetched and processed')),
        );
        downloadedVersions.add(version);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fetch failed: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  void showNextFile() {
    setState(() {
      if (currentIndex < files.length - 1) {
        currentIndex++;
        fileContent = File(files[currentIndex]).readAsStringSync();
        updateSelectedBookAndChapter();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No more files to display')),
        );
      }
    });
  }

  void showPreviousFile() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        fileContent = File(files[currentIndex]).readAsStringSync();
        updateSelectedBookAndChapter();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is the first file')),
        );
      }
    });
  }

  String getVerseLine(int index) {
    final lines = fileContent.split('\n');
    if (index < lines.length) {
      final verseIndex = lines[index].indexOf(':');
      if (verseIndex != -1) {
        // Exclude the book and chapter number from the verse line
        return lines[index].substring(verseIndex + 1).trim();
      }
      return lines[index];
    }
    return '';
  }

  void updateSelectedBookAndChapter() {
    // Iterate through bookChapters to find the selected book and chapter
    int currentFileIndex = 0;
    String? selectedBook;
    int? selectedChapter;

    for (var entry in bookChapters.entries) {
      int chapterCount = entry.value;
      if (currentIndex >= currentFileIndex &&
          currentIndex < currentFileIndex + chapterCount) {
        selectedBook = entry.key;
        selectedChapter = currentIndex - currentFileIndex + 1;
        break;
      }
      currentFileIndex += chapterCount;
    }

    setState(() {
      this.selectedBook = selectedBook;
      this.selectedChapter = selectedChapter;
    });
  }

  List<int> getChapters(String book) {
    int chapters = bookChapters[book]!;
    return List<int>.generate(chapters, (index) => index + 1);
  }

  void loadSelectedChapterContent() {
    if (selectedBook != null && selectedChapter != null) {
      // Calculate the index of the selected chapter within the files array
      int bookIndex = bookChapters.keys.toList().indexOf(selectedBook!);
      int chapterIndex = selectedChapter! - 1;
      currentIndex = 0;
      for (int i = 0; i < bookIndex; i++) {
        currentIndex += bookChapters.values.toList()[i];
      }
      currentIndex += chapterIndex;

      if (currentIndex >= 0 && currentIndex < files.length) {
        setState(() {
          fileContent = File(files[currentIndex]).readAsStringSync();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected chapter not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifove Bible (Single View)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/multi_version');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text('Select a scripture'),
              value: selectedVersion,
              items: fileUrls.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedVersion = newValue;
                  selectedBook = null;
                  selectedChapter = null;
                  fileContent = '';
                });
                if (newValue != null) {
                  fetchFiles(newValue);
                }
              },
            ),
          ),
          if (selectedVersion != null) ...[
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      hint: const Text('Select a book'),
                      value: selectedBook,
                      items: bookChapters.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBook = newValue;
                          selectedChapter = null;
                          fileContent = '';
                        });
                      },
                    ),
                  ),
                ),
                if (selectedBook != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<int>(
                        hint: const Text('Select a chapter'),
                        value: selectedChapter,
                        items: getChapters(selectedBook!).map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedChapter = newValue;
                            fileContent = '';
                          });
                          loadSelectedChapterContent();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: files.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        fileContent.isNotEmpty
                            ? fileContent.split('\n').length
                            : 0,
                        (index) => Text(
                          getVerseLine(index),
                          // You may adjust the style of the verse text as needed
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child:
                        Text('Select a scripture version, book, and chapter'),
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: showPreviousFile,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: showNextFile,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
