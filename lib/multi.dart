import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:lifovebible/bookmark.dart';
import 'package:lifovebible/read.dart';
import 'package:lifovebible/read_index.dart';
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
  String? selectedBook = 'Genesis';
  int? selectedChapter = 1;

  List<String> selectedVerses = [];
  List<String> underlinedVerses = [];
  List<String> bookmarkVerses = [];
  Map<String, String> memo = {};

  int currentIndex = 0;

  Future<void> loadTextFiles() async{
    final directory = await getApplicationDocumentsDirectory();

    await File('${directory.path}/underline.txt').create();
    await File('${directory.path}/bookmark.txt').create();
    await File('${directory.path}/memo.txt').create();

    final underlinedText = File('${directory.path}/underline.txt');
    final bookmarkedText = File('${directory.path}/bookmark.txt');
    final memoText = File('${directory.path}/memo.txt');

    final underlineString = await underlinedText.readAsString();
    final memoString = await memoText.readAsString();
    final bookmarkString = await bookmarkedText.readAsString();

    if (underlineString.length!=0){
      underlinedVerses=underlineString.split('/');
    }
    if (bookmarkString.length!=0){
      bookmarkVerses=bookmarkString.split('/');
    }
    if (memoString.length!=0){
      memoString.split('/').forEach((element) {
        memo[element.split(':')[0]]=element.split(':')[1];
      },);
    }
    setState((){});
  }
  
  Future<void> saveTextFiles() async{
    final directory = await getApplicationDocumentsDirectory();
    final underlinedText = File('${directory.path}/underline.txt');
    final bookmarkedText = File('${directory.path}/bookmark.txt');
    final memoText = File('${directory.path}/memo.txt');

    if (underlinedVerses.isNotEmpty){
      String underlineString='';
      underlinedVerses.forEach((element) {
        underlineString='$underlineString$element/';
      });
      underlineString=underlineString.substring(0,underlineString.length-1);
      await underlinedText.writeAsString(underlineString);
    }

    if (bookmarkVerses.isNotEmpty){
      String bookmarkString='';
      bookmarkVerses.forEach((element) {
        bookmarkString='$bookmarkString$element/';
      });
      bookmarkString=bookmarkString.substring(0,bookmarkString.length-1);
      await bookmarkedText.writeAsString(bookmarkString);
    }

    if(memo.isNotEmpty){
      String memoString='';
      memo.forEach((key,value) {
        memoString='$memoString$key:$value/';
      });
      memoString=memoString.substring(0,memoString.length-1);
      await memoText.writeAsString(memoString);
    }
    setState((){});
  }
  


  Future<void> fetchFiles(String version) async {
    if (downloadedVersions.contains(version)) {
      return;
    }
    var dir = await getApplicationDocumentsDirectory();
    String filePath = path.join(dir.path, fileName);
    String zipFilePath = filePath.replaceAll('.lfa', '.zip');

    if (await Permission.storage.request().isGranted) {
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
            duration: const Duration(milliseconds: 2000),
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
        updateSelectedBookAndChapter();
        loadSelectedBookAndChapter();
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
        updateSelectedBookAndChapter();
        loadSelectedBookAndChapter();
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

  void loadSelectedBookAndChapter() {
    if (selectedBook != null && selectedChapter != null) {
      int bookIndex = bookChapters.keys.toList().indexOf(selectedBook!);
      int chapterIndex = selectedChapter! - 1;
      currentIndex = bookIndex > 0
          ? bookChapters.values.take(bookIndex).fold(0, (a, b) => a + b) +
              chapterIndex
          : chapterIndex;
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

  @override
  Widget build(BuildContext context) {
    setState(() {
      loadTextFiles();
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bible Translation'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => bookmarkPage(bookmarkVerses)),
                  ).then((value) {
                    setState(() {
                      if (value != null) {
                        this.selectedBook = value.split(',')[0];
                        this.selectedChapter = int.parse(value.split(',')[1]);
                        loadSelectedBookAndChapter();
                        saveTextFiles();
                      }
                      // selectedBook=value.split(',')[0];
                      // selectedChapter=value.split(',')[1];
                    });
                  });
                },
                icon: const Icon(Icons.bookmark)),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const readIndexPage()),
                );
              },
              icon: const Icon(Icons.book),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/setting');
              },
            )
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
                      const Text(
                        'Versions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 45, // Adjust the height as needed
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: selectedVersions
                                .map((version) => Text(version))
                                .toList(),
                          ),
                        ),
                      ),
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
                        child: Row(
                          children: [
                            Text(version),
                            if (selectedVersions.contains(version))
                              const Icon(Icons.check),
                          ],
                        ),
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
                      // Group versions in batches of 3
                      List<Widget> versionRows = [];
                      for (int j = 0; j < selectedVersions.length; j += 3) {
                        List<String> versionsBatch =
                            selectedVersions.skip(j).take(3).toList();

                        versionRows.add(
                          IntrinsicHeight(
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              color: selectedVerses.contains(
                                      '$selectedBook,$selectedChapter,$i')
                                  ? Colors.yellow
                                  : null,
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(versionsBatch.length,
                                        (index) {
                                  var version = versionsBatch[index];
                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              getVersionLine(version, i),
                                              style: underlinedVerses.contains(
                                                      '$selectedBook,$selectedChapter,$i')
                                                  ? const TextStyle(
                                                      decoration: TextDecoration
                                                          .underline,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          onTap: () {
                                            setState(() {
                                              if (selectedVerses.contains(
                                                  '$selectedBook,$selectedChapter,$i')) {
                                                selectedVerses.remove(
                                                    '$selectedBook,$selectedChapter,$i');
                                              } else {
                                                selectedVerses.add(
                                                    '$selectedBook,$selectedChapter,$i');
                                              }
                                            });
                                            debugPrint('$selectedVerses');
                                          },
                                          onLongPress: () {
                                            if (memo.containsKey(
                                                '$selectedBook,$selectedChapter,$i')) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('메모 작성'),
                                                    content: Text(memo[
                                                            '$selectedBook,$selectedChapter,$i']
                                                        as String),
                                                    actions: [
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          setState((){
                                                            memo.remove(
                                                                '$selectedBook,$selectedChapter,$i');
                                                            saveTextFiles();
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text('삭제'),
                                                      ),
                                                      OutlinedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('나가기'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                        if (selectedVersions.length - 1 ==
                                            index)
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                if (bookmarkVerses.contains(
                                                    '$selectedBook,$selectedChapter,$i'))
                                                  const Icon(Icons.bookmark),
                                                if (memo.containsKey(
                                                    '$selectedBook,$selectedChapter,$i'))
                                                  const Icon(Icons.note),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                })
                                    .expand((element) => [
                                          element,
                                          const VerticalDivider(), // Add a vertical divider after each pair of columns
                                        ])
                                    .toList()
                                    .sublist(
                                      0,
                                      2 * versionsBatch.length - 1,
                                    ), // Remove the last vertical divider
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...versionRows,
                          const Divider(), // Add a horizontal divider between each group of version rows
                        ],
                      );
                    },
                  ).toList(),
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (selectedBook != null && selectedChapter != null) {
                        // readBible.add("$selectedVersions $selectedBook $selectedChapter");
                        bool chapterRead = false;
                        for (int i = 0; i < reads.length; i++) {
                          if (selectedChapter == 1) {
                            reads[i].setRead(selectedBook!, selectedChapter!);
                            chapterRead = true;
                          } else {
                            bool cond = reads[i].getRead(
                                    selectedBook!, selectedChapter! - 1) ??
                                false;
                            if (cond) {
                              reads[i].setRead(selectedBook!, selectedChapter!);
                              chapterRead = true;
                            } else {
                              chapterRead = false;
                            }
                          }
                        }
                        if (chapterRead = true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Read!!"),
                              duration: Duration(milliseconds: 300),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("You didn't read previous chapter..."),
                              duration: Duration(milliseconds: 1000),
                            ),
                          );
                        }

                        // for(var version in selectedVersions) {
                        //     if(selectedChapter == 0 || readStatus[version]![selectedBook]?[selectedChapter!-1] == true) {
                        //       readStatus[version]![selectedBook]?[selectedChapter!] = true;
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text("Read!!"),
                        //           duration: Duration(milliseconds: 300),
                        //         ),
                        //       );
                        //     }
                        //     else {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text("You didn't read previous chapter..."),
                        //           duration: Duration(milliseconds: 1000),
                        //         ),
                        //       );
                        //     }
                        //   }
                      }
                    });
                  },
                  child: const Text("Read"),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: showNextFile,
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: selectedVerses.isEmpty
            ? null
            : Container(
                margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          color: Colors.grey,
                          child: TextButton(
                              child: const Text('밑줄긋기'),
                              onPressed: () {
                                debugPrint('button Clicked');
                                setState((){
                                  for (var element in selectedVerses) {
                                    if (underlinedVerses.contains(element)) {
                                      underlinedVerses.remove(element);
                                    } else {
                                      underlinedVerses.add(element);
                                    }
                                  }
                                  selectedVerses.clear();
                                  saveTextFiles();
                                });
                              }))),
                  ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          color: Colors.grey,
                          child: TextButton(
                              child: const Text('즐겨찾기'),
                              onPressed: () {
                                debugPrint('button Clicked');
                                setState(() {
                                  selectedVerses.forEach(
                                    (element) {
                                      if (bookmarkVerses.contains(element)) {
                                        bookmarkVerses.remove(element);
                                      } else {
                                        bookmarkVerses.add(element);
                                      }
                                    },
                                  );
                                  selectedVerses.clear();
                                  bookmarkVerses.sort();
                                  saveTextFiles();
                                });
                                debugPrint('${bookmarkVerses.length}');
                              }))),
                  ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          color: Colors.grey,
                          child: TextButton(
                              child: const Text('메모'),
                              onPressed: () async {
                                if (selectedVerses.length != 1) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            title: Text('메모기능'),
                                            content: Text(
                                                '메모기능은 한 개의 구절만 선택 가능합니다.'),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('확인'),
                                              ),
                                            ]);
                                      });
                                } else {
                                  var tmp = TextEditingController();
                                  if (memo.containsKey(selectedVerses[0])) {
                                    tmp = TextEditingController(
                                        text: memo[selectedVerses[0]]);
                                  }
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            title: Text('메모 작성'),
                                            content: TextField(controller: tmp),
                                            actions: [
                                              OutlinedButton(
                                                onPressed: () {
                                                  debugPrint(selectedVerses[0]);
                                                  debugPrint(tmp.text);
                                                  setState(() {
                                                    memo[selectedVerses[0]] =
                                                        tmp.text;
                                                    selectedVerses.clear();
                                                    saveTextFiles();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('저장'),
                                              ),
                                              OutlinedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('취소'),
                                              ),
                                            ]);
                                      });
                                }
                              }))),
                  ClipOval(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          color: Colors.grey,
                          child: TextButton(
                              child: const Text('복사'),
                              onPressed: () {
                                debugPrint('button Clicked');
                              }))),
                ])));
  }
}
