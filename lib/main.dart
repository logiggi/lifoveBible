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
    '흠정역' : 'https://lifovebible.github.io/data/korHKJV.lfa',
    '개역한글국한문': 'https://lifovebible.github.io/data/kchhrv.lfa',
    '가톨릭성경' : 'https://lifovebible.github.io/data/korcath.lfa',
    '中文英皇欽定本上帝版繁體' : 'https://lifovebible.github.io/data/ckjv.lfa',
    '中文英皇欽定本神版繁體' : 'https://lifovebible.github.io/data/ckjvgod.lfa',
    '中文英皇钦定本上帝版简体' : 'https://lifovebible.github.io/data/ckjvsimp.lfa',
    '中文英皇钦定本神版简体' : 'https://lifovebible.github.io/data/ckjvsimpgod.lfa',
    '新译本简体' : 'https://lifovebible.github.io/data/chnncv.lfa',
    '新译本繁體' : 'https://lifovebible.github.io/data/chnncvtr.lfa',
    '和合本简体' : 'https://lifovebible.github.io/data/chnunisimpnospace.lfa',
    '和合本繁體' : 'https://lifovebible.github.io/data/chuniwospace.lfa',
    '思高繁体聖經' : 'https://lifovebible.github.io/data/chncath.lfa',
    'KJV' : 'https://lifovebible.github.io/data/engkjv.lfa',
    'ASV' : 'https://lifovebible.github.io/data/engasv.lfa',
    'Darby' : 'https://lifovebible.github.io/data/engdrb.lfa',
    'ESV' : 'https://lifovebible.github.io/data/engesv.lfa',
    'GNT' : 'https://lifovebible.github.io/data/enggnt.lfa',
    'Weymouth(NT)' : 'https://lifovebible.github.io/data/engwmt.lfa',
    'YLT' : 'https://lifovebible.github.io/data/engylt.lfa',
    'Albanian(Bibla e Shenjtë)' : 'https://lifovebible.github.io/data/albanian.lfa',
    'Bulgarian(БЪЛГАРСКА БИБЛИЯ)' : 'https://lifovebible.github.io/data/croatian.lfa',
    'Croatian(BIBLIJA)' : 'https://lifovebible.github.io/data/amharic.lfa',
    'Czech(česko Bible)' : 'https://lifovebible.github.io/data/czech.lfa',
    'Danish(Bibelen)' : 'https://lifovebible.github.io/data/danish.lfa',
    'Dutch(De Bijbel)' : 'https://lifovebible.github.io/data/dutch.lfa',
    'Finnish(PyhäRaamattu)' : 'https://lifovebible.github.io/data/finpr.lfa',
    'PyhäRaamattu(1933/1938)' : 'https://lifovebible.github.io/data/finpr38.lfa',
    'French(Darby)' : 'https://lifovebible.github.io/data/frdarby.lfa',
    'French(L.Segond)' : 'https://lifovebible.github.io/data/frsegond.lfa',
    'German(Luther)' : 'https://lifovebible.github.io/data/gerlut.lfa',
    'Greek(Septuagint/OT)' : 'https://lifovebible.github.io/data/grestg.lfa',
    'Greek(Stephanos/NT)' : 'https://lifovebible.github.io/data/grestp.lfa',
    'Transliterated(OT)' : 'https://lifovebible.github.io/data/hbrtrl.lfa',
    'Hebrew(Modern)' : 'https://lifovebible.github.io/data/hebmod.lfa',
    'HebrewOT(BHS)NT' : 'https://lifovebible.github.io/data/hebrewbhs.lfa',
    'HebrewOT(WLC)' : 'https://lifovebible.github.io/data/hebrewwlc.lfa',
    'Hungarian(Biblia)' : 'https://lifovebible.github.io/data/hungarian.lfa',
    'Hindi(पवित्र बाइबिल)' : 'https://lifovebible.github.io/data/hindi.lfa',
    'Icelandic(Biblían)' : 'https://lifovebible.github.io/data/icelandic.lfa',
    'IndonesiaTer.Baru' : 'https://lifovebible.github.io/data/idntbaru.lfa',
    'Japanese(口語訳)' : 'https://lifovebible.github.io/data/jpnjct.lfa',
    'Japanese(新改訳)' : 'https://lifovebible.github.io/data/jpnnew.lfa',
    'Japanese(新共同訳)' : 'https://lifovebible.github.io/data/jpnnit.lfa',
    'Latin(Vulgate)' : 'https://lifovebible.github.io/data/latvul.lfa',
    'Lithuanian' : 'https://lifovebible.github.io/data/lith.lfa',
    'Malagasy' : 'https://lifovebible.github.io/data/malagasy.lfa',
    'Persian(کتاب مقدس)' : 'https://lifovebible.github.io/data/persian.lfa',
    'Portuguese' : 'https://lifovebible.github.io/data/prtaa.lfa',
    'Russian(Synodal)' : 'https://lifovebible.github.io/data/russyn.lfa',
    'Spanish(ReinaValera1960)' : 'https://lifovebible.github.io/data/spnrei.lfa',
    'Tagalog' : 'https://lifovebible.github.io/data/tagalog.lfa',
    'Tagalog(Mag.Bal.)' : 'https://lifovebible.github.io/data/tagamag.lfa',
    'Thai' : 'https://lifovebible.github.io/data/thai.lfa',
    'Turkish' : 'https://lifovebible.github.io/data/turkish.lfa',
    'Vietnamese' : 'https://lifovebible.github.io/data/vietnamese.lfa',
    'Myanmarese' : 'https://lifovebible.github.io/data/my.lfa',
    'Amharic(መጽሐፍ ቅዱስ)' : 'https://lifovebible.github.io/data/amharic.lfa,Amharic',
    'Bengali(পবিত্র বাইবেল)' : 'https://lifovebible.github.io/data/bengali.lfa',
    'Italian(La Sacra Bibbia)' : 'https://lifovebible.github.io/data/italian.lfa',
    'Kannada(ಪವಿತ್ರ ಬೈಬಲ್)' : 'https://lifovebible.github.io/data/kannada.lfa',
    'Luganda(Baibuli y\'Oluganda)' : 'https://lifovebible.github.io/data/luganda.lfa'
  };
  final String fileName = 'kornkrv.lfa';
  List<String> files = [];
  int currentIndex = 0;
  String fileContent = '';
  String? selectedText;

  Future<void> fetchFiles(String version) async {
    var dir = await getApplicationDocumentsDirectory();
    String filePath = path.join(dir.path, fileName);
    String zipFilePath = filePath.replaceAll('.lfa', '.zip');

    if (await Permission.storage.request().isGranted) {
      try {
        // 파일 다운로드
        await Dio().download(fileUrls[version]!, filePath);
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
        title: Text('Lifove Bible'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Select a scripture'),
              value: selectedText,
              items: fileUrls.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedText = newValue;
                });
                if (newValue != null) {
                  fetchFiles(newValue);
                }
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: files.isNotEmpty
                ? SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Text(fileContent),
            )
                : Center(child: Text('Select a scripture')),
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
