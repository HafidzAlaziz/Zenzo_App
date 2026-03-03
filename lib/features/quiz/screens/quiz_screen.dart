import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/learning_data_service.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/widgets/writing_animation.dart';
import '../../../core/widgets/ai_error_widget.dart';

class QuizScreen extends StatefulWidget {
  final String? customMaterial;
  final String initialModel;

  const QuizScreen({
    super.key,
    this.customMaterial,
    this.initialModel = 'gemini-flash-latest',
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _isLoading = true;
  int? _selectedOption;
  bool _showFeedback = false;
  String _errorMessage = '';
  late String _selectedModel;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    _loadQuizQuestions();
  }

  Future<void> _loadQuizQuestions() async {
    final material =
        widget.customMaterial ?? LearningDataService().getRandomMaterial();

    if (material == null) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Belum ada materi yang kamu pelajari. Rangkum materi atau buat flashcard dulu ya!';
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    final questions = await GeminiService.generateQuizQuestions(
      material,
      model: _selectedModel,
    );

    if (mounted) {
      setState(() {
        if (questions.isEmpty) {
          _errorMessage =
              'Waduh, AI-nya lagi sibuk (Error 503/429). Coba ganti model atau refresh ya!';
        } else {
          _quizQuestions = questions;
          _errorMessage = '';
        }
        _isLoading = false;
      });
    }
  }

  void _submitAnswer() {
    if (_showFeedback) {
      if (_currentQuestionIndex < _quizQuestions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
          _showFeedback = false;
        });
      } else {
        StatisticsService().incrementQuizzes();
        StatisticsService().addStudyTime(5);
        setState(() {
          _isFinished = true;
        });
      }
    } else {
      if (_selectedOption == _quizQuestions[_currentQuestionIndex]['answer']) {
        _score++;
      }
      setState(() {
        _showFeedback = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: WritingAnimation(text: 'AI sedang meramu soal latihan... 🧪'),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Latihan Soal'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Column(
          children: [
            _buildModelSelector(),
            Expanded(
              child: AiErrorWidget(
                errorMessage: _errorMessage,
                onRetry: _loadQuizQuestions,
              ),
            ),
          ],
        ),
      );
    }

    if (_isFinished) return _buildResultView();

    final question = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Latihan Soal AI ✨'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          _buildModelSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _quizQuestions.length,
                    backgroundColor: AppColors.primaryTeal.withOpacity(0.1),
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.primaryTeal,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Pertanyaan ${_currentQuestionIndex + 1}/${_quizQuestions.length}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question['question'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate((question['options'] as List).length, (
                    index,
                  ) {
                    final option = question['options'][index];
                    final isSelected = _selectedOption == index;
                    final isCorrect = question['answer'] == index;

                    Color bgColor = Colors.white;
                    Color borderColor = Colors.grey.withOpacity(0.2);
                    Color contentColor = AppColors.textPrimary;
                    IconData? resultIcon;

                    if (_showFeedback) {
                      if (isCorrect) {
                        bgColor = Colors.green.withOpacity(0.1);
                        borderColor = Colors.green;
                        contentColor = Colors.green;
                        resultIcon = Icons.check_circle_rounded;
                      } else if (isSelected) {
                        bgColor = Colors.red.withOpacity(0.1);
                        borderColor = Colors.red;
                        contentColor = Colors.red;
                        resultIcon = Icons.cancel_rounded;
                      }
                    } else if (isSelected) {
                      bgColor = AppColors.primaryTeal.withOpacity(0.1);
                      borderColor = AppColors.primaryTeal;
                      contentColor = AppColors.primaryTeal;
                    }

                    return GestureDetector(
                      onTap: _showFeedback
                          ? null
                          : () => setState(() => _selectedOption = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(color: borderColor, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            if (resultIcon != null)
                              Icon(resultIcon, size: 24, color: contentColor)
                            else
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryTeal
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppColors.primaryTeal
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                option.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      isSelected || (_showFeedback && isCorrect)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: contentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _selectedOption == null ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      !_showFeedback
                          ? 'Periksa Jawaban'
                          : (_currentQuestionIndex < _quizQuestions.length - 1
                                ? 'Lanjut'
                                : 'Selesai'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modelChip('Flash', 'gemini-flash-latest'),
          const SizedBox(width: 12),
          _modelChip('Pro', 'gemini-1.5-pro-latest'),
        ],
      ),
    );
  }

  Widget _modelChip(String label, String modelId) {
    bool isSelected = _selectedModel == modelId;
    String? status = GeminiService.getModelStatus(modelId);
    bool isBusy = status != null;

    return ActionChip(
      onPressed: () {
        if (_selectedModel == modelId) return;
        setState(() {
          _selectedModel = modelId;
          _isLoading = true;
          _errorMessage = '';
        });
        _loadQuizQuestions();
      },
      backgroundColor: isSelected ? AppColors.primaryTeal : Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
      ),
      avatar: isBusy
          ? const Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: Colors.orange,
            )
          : null,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildResultView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 100,
                color: AppColors.zenGold,
              ),
              const SizedBox(height: 24),
              const Text(
                'Latihan Selesai!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Skor kamu: $_score / ${_quizQuestions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
