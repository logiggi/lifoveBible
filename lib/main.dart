import 'package:flutter/material.dart';
import 'multi.dart'; // Import the MultiVersionPage widget
import 'single.dart'; // Assuming your original MyHomePage is renamed to SingleVersionPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

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

      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SingleVersionPage(),
        '/multi_version': (context) => const MultiVersionPage(),
      },
    );
  }
}
