import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lifovebible/read.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'data.dart'; // Ensure data.dart is imported

class bookmarkPage extends StatefulWidget {
  const bookmarkPage(this.bookmarkVerses, {super.key});

  final List<String> bookmarkVerses;
  // List<String> bookmarkedVerses=bookmarkVerses;
  @override
  _bookmarkPage createState() => _bookmarkPage();
}

class _bookmarkPage extends State<bookmarkPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint('${widget.bookmarkVerses}');
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)
        ),
        title: Text('Bookmark Page'),
      ),
      body: ListView(
          children: 
            widget.bookmarkVerses.map((verse){
              return ListTile(
                title:Text('${verse.split(',')[0]} ${verse.split(',')[1]}:${int.parse(verse.split(',')[2])+1}'),
                trailing: Wrap(
                  spacing:5,
                  children:[
                    IconButton(
                    icon:const Icon(Icons.arrow_circle_right),
                    onPressed:(){
                      debugPrint('click!');
                      Navigator.pop(context,verse);
                    }
                  ),
                    IconButton(
                    icon:const Icon(Icons.delete),
                    onPressed:(){
                      debugPrint('click!');
                      setState((){
                        widget.bookmarkVerses.remove(verse);
                      });
                    }
                  ),
                ]
              ));
            }).toList(),
      )
    );
  }
}
