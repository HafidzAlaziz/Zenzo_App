import 'package:flutter/foundation.dart';

class LearningDataService {
  static final LearningDataService _instance = LearningDataService._internal();
  factory LearningDataService() => _instance;
  LearningDataService._internal();

  // Stores the text of materials the user has summarized or used for flashcards
  final List<String> _materialHistory = [];

  void addMaterial(String text) {
    if (text.trim().isEmpty) return;
    // Don't add duplicates
    if (!_materialHistory.contains(text.trim())) {
      _materialHistory.add(text.trim());
      if (kDebugMode) {
        print(
          'Added to Learning History. Total items: ${_materialHistory.length}',
        );
      }
    }
  }

  List<String> get history => List.unmodifiable(_materialHistory);

  String? getRandomMaterial() {
    if (_materialHistory.isEmpty) return null;
    final random = DateTime.now().millisecond % _materialHistory.length;
    return _materialHistory[random];
  }

  bool get hasHistory => _materialHistory.isNotEmpty;
}
