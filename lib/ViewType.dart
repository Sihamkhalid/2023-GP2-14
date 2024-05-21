import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

enum ViewType { chart, text }

class ViewTypeProvider with ChangeNotifier {
  ViewType _viewType = ViewType.text;

  ViewType get viewType => _viewType;

  void toggleView() {
    _viewType = _viewType == ViewType.text ? ViewType.chart : ViewType.text;
    notifyListeners();
  }
}

