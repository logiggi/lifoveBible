import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class MultiVersionPage extends StatefulWidget {
  const MultiVersionPage({super.key});

  @override
  _MultiVersionPageState createState() => _MultiVersionPageState();
}

class _MultiVersionPageState extends State<MultiVersionPage> {
  String fileName = 'kornkrv.lfa';
  String? selectedBook;
  int? selectedChapter;

  int currentIndex = 0;

  Future<void> fetchFiles(String version) async {
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
            duration: Duration(milliseconds: 300),
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

  void showNextFile() {
    setState(() {
      if (currentIndex < filesMap[selectedVersions.first]!.length - 1) {
        currentIndex++;
        fileContents.clear();
        for (var version in selectedVersions) {
          print(version);
          print(currentIndex);
          if (filesMap.containsKey(version)) {
            fileContents[version] =
                File(filesMap[version]![currentIndex]).readAsStringSync();
          }
        }
        updateSelectedBookAndChapter();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No more files to display'),
            duration: Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  void showPreviousFile() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        fileContents.clear();
        for (var version in selectedVersions) {
          if (filesMap.containsKey(version)) {
            fileContents[version] =
                File(filesMap[version]![currentIndex]).readAsStringSync();
          }
        }
        updateSelectedBookAndChapter();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No more files to display'),
            duration: Duration(milliseconds: 300),
          ),
        );
      }
    });
  }

  String getVersionLine(String version, int index) {
    final lines = (fileContents[version] ?? '').split('\n');
    if (index < lines.length) {
      final verseIndex = lines[index].indexOf(':');
      if (verseIndex != -1) {
        return lines[index].substring(verseIndex + 1).trim();
      }
      return lines[index];
    }
    return '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Version Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Versions:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    for (var version in selectedVersions) Text(version),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (String version) async {
                  setState(() {
                    if (selectedVersions.contains(version)) {
                      selectedVersions.remove(version);
                    } else {
                      selectedVersions.add(version);
                    }
                  });
                  if (selectedVersions.contains(version)) {
                    await fetchFiles(version);
                    loadSelectedBookAndChapter();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return fileUrls.keys.map((String version) {
                    return PopupMenuItem<String>(
                      value: version,
                      child: Text(version),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedBook,
                    hint: const Text('Select Book'),
                    onChanged: (newValue) {
                      setState(() {
                        selectedBook = newValue;
                        selectedChapter = null; // Reset chapter selection
                      });
                    },
                    items: bookChapters.keys.map((book) {
                      return DropdownMenuItem<String>(
                        value: book,
                        child: Text(book),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedChapter,
                  hint: const Text('Select Chapter'),
                  onChanged: (newValue) {
                    setState(() {
                      selectedChapter = newValue;
                      loadSelectedBookAndChapter();
                    });
                  },
                  items: selectedBook != null
                      ? List<int>.generate(bookChapters[selectedBook!]!,
                          (index) => index + 1).map((chapter) {
                          return DropdownMenuItem<int>(
                            value: chapter,
                            child: Text('Chapter $chapter'),
                          );
                        }).toList()
                      : [],
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  (fileContents[selectedVersions.first] ?? '')
                      .split('\n')
                      .length,
                  (i) {
                    return Container(
                      padding: const EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(selectedVersions.length, (index) {
                            var version = selectedVersions[index];
                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getVersionLine(version, i),
                                  ),
                                ],
                              ),
                            );
                          })
                                  .expand((element) => [
                                        element,
                                        const VerticalDivider(), // Add a vertical divider after each pair of columns
                                      ])
                                  .toList(),
                        ),
                      ),
                    );
                  },
                )
                    .expand((element) => [
                          element,
                          const Divider(), // Add a horizontal divider between each pair of verses
                        ])
                    .toList(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: showPreviousFile,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: showNextFile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
