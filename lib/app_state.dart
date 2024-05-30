import 'package:flutter/material.dart';

class SettingProvider with ChangeNotifier {
  double _fontSize = 14;
  double get fontSize => _fontSize;

  void setFontSize(double fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }
}