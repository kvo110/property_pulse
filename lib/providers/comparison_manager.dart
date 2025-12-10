// providers/comparison_manager.dart
import 'package:flutter/foundation.dart';

class ComparisonManager extends ChangeNotifier {
  final List<Map<String, dynamic>> _selected = [];

  List<Map<String, dynamic>> get selected => _selected;

  bool isSelected(String id) {
    return _selected.any((p) => p["id"] == id);
  }

  void toggleProperty(Map<String, dynamic> property) {
    final existingIndex = _selected.indexWhere(
      (p) => p["id"] == property["id"],
    );

    if (existingIndex >= 0) {
      _selected.removeAt(existingIndex);
    } else {
      if (_selected.length < 3) {
        _selected.add(property);
      }
    }
    notifyListeners();
  }

  void clear() {
    _selected.clear();
    notifyListeners();
  }
}
