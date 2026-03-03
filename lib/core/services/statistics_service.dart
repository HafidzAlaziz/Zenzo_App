import 'package:flutter/foundation.dart';
import 'learning_data_service.dart';

class StatisticsService extends ChangeNotifier {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  int _flashcardsPlayed = 0;
  int _quizzesCompleted = 0;
  int _studyTimeMinutes = 0;

  // Stores study minutes per day (0 for today, 6 for 6 days ago)
  final Map<int, int> _weeklyStudyMinutes = {
    0: 0,
    1: 45,
    2: 30,
    3: 60,
    4: 20,
    5: 40,
    6: 15,
  };

  int get flashcardsPlayed => _flashcardsPlayed;
  int get quizzesCompleted => _quizzesCompleted;
  int get studyTimeMinutes => _studyTimeMinutes;
  int get materialsSummarized => LearningDataService().history.length;
  List<int> get weeklyData =>
      List.generate(7, (i) => _weeklyStudyMinutes[6 - i] ?? 0);

  void incrementFlashcards() {
    _flashcardsPlayed++;
    notifyListeners();
  }

  void incrementQuizzes() {
    _quizzesCompleted++;
    notifyListeners();
  }

  void addStudyTime(int minutes) {
    _studyTimeMinutes += minutes;
    _weeklyStudyMinutes[0] = (_weeklyStudyMinutes[0] ?? 0) + minutes;
    notifyListeners();
  }
}
