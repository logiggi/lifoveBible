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
  final Map<String, String> fileUrls = {
    '개역개정': 'https://lifovebible.github.io/data/kornkrv.lfa',
    '바른성경': 'https://lifovebible.github.io/data/korktv.lfa',
    '개역한글': 'https://lifovebible.github.io/data/korhrv.lfa',
    '흠정역': 'https://lifovebible.github.io/data/korHKJV.lfa',
    '개역한글국한문': 'https://lifovebible.github.io/data/kchhrv.lfa',
    '가톨릭성경': 'https://lifovebible.github.io/data/korcath.lfa',
    '中文英皇欽定本上帝版繁體': 'https://lifovebible.github.io/data/ckjv.lfa',
    '中文英皇欽定本神版繁體': 'https://lifovebible.github.io/data/ckjvgod.lfa',
    '中文英皇钦定本上帝版简体': 'https://lifovebible.github.io/data/ckjvsimp.lfa',
    '中文英皇钦定本神版简体': 'https://lifovebible.github.io/data/ckjvsimpgod.lfa',
    '新译本简体': 'https://lifovebible.github.io/data/chnncv.lfa',
    '新译本繁體': 'https://lifovebible.github.io/data/chnncvtr.lfa',
    '和合本简体': 'https://lifovebible.github.io/data/chnunisimpnospace.lfa',
    '和合本繁體': 'https://lifovebible.github.io/data/chuniwospace.lfa',
    '思高繁体聖經': 'https://lifovebible.github.io/data/chncath.lfa',
    'KJV': 'https://lifovebible.github.io/data/engkjv.lfa',
    'ASV': 'https://lifovebible.github.io/data/engasv.lfa',
    'Darby': 'https://lifovebible.github.io/data/engdrb.lfa',
    'ESV': 'https://lifovebible.github.io/data/engesv.lfa',
    'GNT': 'https://lifovebible.github.io/data/enggnt.lfa',
    'Weymouth(NT)': 'https://lifovebible.github.io/data/engwmt.lfa',
    'YLT': 'https://lifovebible.github.io/data/engylt.lfa',
    'Albanian(Bibla e Shenjtë)':
        'https://lifovebible.github.io/data/albanian.lfa',
    'Bulgarian(БЪЛГАРСКА БИБЛИЯ)':
        'https://lifovebible.github.io/data/croatian.lfa',
    'Croatian(BIBLIJA)': 'https://lifovebible.github.io/data/amharic.lfa',
    'Czech(česko Bible)': 'https://lifovebible.github.io/data/czech.lfa',
    'Danish(Bibelen)': 'https://lifovebible.github.io/data/danish.lfa',
    'Dutch(De Bijbel)': 'https://lifovebible.github.io/data/dutch.lfa',
    'Finnish(PyhäRaamattu)': 'https://lifovebible.github.io/data/finpr.lfa',
    'PyhäRaamattu(1933/1938)': 'https://lifovebible.github.io/data/finpr38.lfa',
    'French(Darby)': 'https://lifovebible.github.io/data/frdarby.lfa',
    'French(L.Segond)': 'https://lifovebible.github.io/data/frsegond.lfa',
    'German(Luther)': 'https://lifovebible.github.io/data/gerlut.lfa',
    'Greek(Septuagint/OT)': 'https://lifovebible.github.io/data/grestg.lfa',
    'Greek(Stephanos/NT)': 'https://lifovebible.github.io/data/grestp.lfa',
    'Transliterated(OT)': 'https://lifovebible.github.io/data/hbrtrl.lfa',
    'Hebrew(Modern)': 'https://lifovebible.github.io/data/hebmod.lfa',
    'HebrewOT(BHS)NT': 'https://lifovebible.github.io/data/hebrewbhs.lfa',
    'HebrewOT(WLC)': 'https://lifovebible.github.io/data/hebrewwlc.lfa',
    'Hungarian(Biblia)': 'https://lifovebible.github.io/data/hungarian.lfa',
    'Hindi(पवित्र बाइबिल)': 'https://lifovebible.github.io/data/hindi.lfa',
    'Icelandic(Biblían)': 'https://lifovebible.github.io/data/icelandic.lfa',
    'IndonesiaTer.Baru': 'https://lifovebible.github.io/data/idntbaru.lfa',
    'Japanese(口語訳)': 'https://lifovebible.github.io/data/jpnjct.lfa',
    'Japanese(新改訳)': 'https://lifovebible.github.io/data/jpnnew.lfa',
    'Japanese(新共同訳)': 'https://lifovebible.github.io/data/jpnnit.lfa',
    'Latin(Vulgate)': 'https://lifovebible.github.io/data/latvul.lfa',
    'Lithuanian': 'https://lifovebible.github.io/data/lith.lfa',
    'Malagasy': 'https://lifovebible.github.io/data/malagasy.lfa',
    'Persian(کتاب مقدس)': 'https://lifovebible.github.io/data/persian.lfa',
    'Portuguese': 'https://lifovebible.github.io/data/prtaa.lfa',
    'Russian(Synodal)': 'https://lifovebible.github.io/data/russyn.lfa',
    'Spanish(ReinaValera1960)': 'https://lifovebible.github.io/data/spnrei.lfa',
    'Tagalog': 'https://lifovebible.github.io/data/tagalog.lfa',
    'Tagalog(Mag.Bal.)': 'https://lifovebible.github.io/data/tagamag.lfa',
    'Thai': 'https://lifovebible.github.io/data/thai.lfa',
    'Turkish': 'https://lifovebible.github.io/data/turkish.lfa',
    'Vietnamese': 'https://lifovebible.github.io/data/vietnamese.lfa',
    'Myanmarese': 'https://lifovebible.github.io/data/my.lfa',
    'Amharic(መጽሐፍ ቅዱስ)':
        'https://lifovebible.github.io/data/amharic.lfa,Amharic',
    'Bengali(পবিত্র বাইবেল)': 'https://lifovebible.github.io/data/bengali.lfa',
    'Italian(La Sacra Bibbia)':
        'https://lifovebible.github.io/data/italian.lfa',
    'Kannada(ಪವಿತ್ರ ಬೈಬಲ್)': 'https://lifovebible.github.io/data/kannada.lfa',
    'Luganda(Baibuli y\'Oluganda)':
        'https://lifovebible.github.io/data/luganda.lfa'
  };
  final Set<String> downloadedVersions = {};
  final Map<String, int> bookChapters = {
    '01Gn': 50, // Genesis
    '02Ex': 40, // Exodus
    '03Lv': 27, // Leviticus
    '04Nm': 36, // Numbers
    '05Dt': 34, // Deuteronomy
    '06Js': 24, // Joshua
    '07Jg': 21, // Judges
    '08Rt': 4, // Ruth
    '09Sa1': 31, // 1 Samuel
    '10Sa2': 24, // 2 Samuel
    '11Kg1': 22, // 1 Kings
    '12Kg2': 25, // 2 Kings
    '13Ch1': 29, // 1 Chronicles
    '14Ch2': 36, // 2 Chronicles
    '15Ezr': 10, // Ezra
    '16Ne': 13, // Nehemiah
    '17Est': 10, // Esther
    '18Job': 42, // Job
    '19Ps': 150, // Psalms
    '20Pr': 31, // Proverbs
    '21Ec': 12, // Ecclesiastes
    '22SS': 8, // Song of Solomon
    '23Is': 66, // Isaiah
    '24Jr': 52, // Jeremiah
    '25Lm': 5, // Lamentations
    '26Ezk': 48, // Ezekiel
    '27Dn': 12, // Daniel
    '28Hos': 14, // Hosea
    '29Jl': 3, // Joel
    '30Am': 9, // Amos
    '31Ob': 1, // Obadiah
    '32Jon': 4, // Jonah
    '33Mi': 7, // Micah
    '34Nah': 3, // Nahum
    '35Hab': 3, // Habakkuk
    '36Zep': 3, // Zephaniah
    '37Hag': 2, // Haggai
    '38Zech': 14, // Zechariah
    '39Mal': 4, // Malachi
    '40Mt': 28, // Matthew
    '41Mk': 16, // Mark
    '42Lk': 24, // Luke
    '43Jn': 21, // John
    '44Acts': 28, // Acts
    '45Rm': 16, // Romans
    '46Co1': 16, // 1 Corinthians
    '47Co2': 13, // 2 Corinthians
    '48Gl': 6, // Galatians
    '49Ep': 6, // Ephesians
    '50Phl': 4, // Philippians
    '51Cl': 4, // Colossians
    '52Th1': 5, // 1 Thessalonians
    '53Th2': 3, // 2 Thessalonians
    '54Tm1': 6, // 1 Timothy
    '55Tm2': 4, // 2 Timothy
    '56Tt': 3, // Titus
    '57Phm': 1, // Philemon
    '58Hb': 13, // Hebrews
    '59Jm': 5, // James
    '60Pt1': 5, // 1 Peter
    '61Pt2': 3, // 2 Peter
    '62Jn1': 5, // 1 John
    '63Jn2': 1, // 2 John
    '64Jn3': 1, // 3 John
    '65Jude': 1, // Jude
    '66Rv': 22, // Revelation
  };

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

    if (true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading and processing files...')),
        );
        // 파일 다운로드
        // ignore: use_build_context_synchronously
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
          SnackBar(content: Text('Files fetched and processed')),
        );
        downloadedVersions.add(version);
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
        updateSelectedBookAndChapter();
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
        updateSelectedBookAndChapter();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This is the first file')),
        );
      }
    });
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
          SnackBar(content: Text('Selected chapter not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lifove Bible'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Select a scripture'),
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
                      hint: Text('Select a book'),
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
                        hint: Text('Select a chapter'),
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
          SizedBox(height: 20),
          Expanded(
            child: files.isNotEmpty
                ? SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Text(fileContent),
                  )
                : Center(
                    child:
                        Text('Select a scripture version, book, and chapter')),
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
