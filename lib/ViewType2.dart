import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

enum ViewType2 { chart, text }

class ViewTypeProvider2 with ChangeNotifier {
  ViewType2 _viewType2 = ViewType2.text;

  ViewType2 get viewType2 => _viewType2;

  void toggleView2() {
    _viewType2 =
        _viewType2 == ViewType2.text ? ViewType2.chart : ViewType2.text;
    notifyListeners();
  }
}
