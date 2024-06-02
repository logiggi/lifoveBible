import 'package:flutter/material.dart';
import 'data.dart'; // Ensure data.dart is imported

class ReadPage extends StatefulWidget {
  final String bibleVersion;

  const ReadPage({super.key, required this.bibleVersion});

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  String readCount(String book) {
    int ret = 0;
    for (int i = 0; i < reads.length; i++) {
      if (reads[i].getVersion() == widget.bibleVersion) {
        int len = reads[i].getLength(book) ?? 0;
        for (int j = 0; j < len; j++) {
          bool val = reads[i].getRead(book, j) ?? false;
          ret += (val ? 1 : 0);
        }
      }
    }
    return ret.toString();
  }

  void _clearReadStatus() {
    setState(() {
      for (int i = 0; i < reads.length; i++) {
        if (reads[i].getVersion() == widget.bibleVersion) {
          reads[i].clearAllReads();
        }
      }
    });
  }

  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Clear'),
          content: Text('Are you sure you want to clear all read statuses?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _clearReadStatus(); // Call the clear function
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
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
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Read status'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: bookChapters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(books[index]),
                  trailing: Text(
                    readCount(books[index]) + ' / ' + chapters[index].toString(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _showClearConfirmationDialog,
              child: Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }
}
