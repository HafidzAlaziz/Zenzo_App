import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/widgets/writing_animation.dart';
import '../../../core/widgets/ai_error_widget.dart';
import '../../../core/widgets/flip_card.dart';
import 'flashcard_screen.dart';

class AiSummaryScreen extends StatefulWidget {
  final String title;
  final String content;
  final String initialModel;

  const AiSummaryScreen({
    super.key,
    required this.title,
    required this.content,
    this.initialModel = 'gemini-flash-latest',
  });

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String _errorMessage = '';
  late String _selectedModel;
  final Map<int, bool> _flippedCards = {};
  final Map<int, int?> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    final result = await GeminiService.summarizeMaterialRich(
      widget.content,
      model: _selectedModel,
    );
    if (mounted) {
      setState(() {
        if (result.containsKey('error')) {
          _errorMessage = result['error'].toString();
        } else {
          _data = result;
          _errorMessage = '';
        }
        _isLoading = false;
      });
    }
  }

  void _switchModel(String model) {
    if (_selectedModel == model) return;
    setState(() {
      _selectedModel = model;
      _isLoading = true;
      _errorMessage = '';
    });
    _generateSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F4),
      appBar: AppBar(
        title: const Text('Rangkuman Super ✨'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildModelSelector(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: WritingAnimation(
                      text: 'AI sedang merangkum materi... ✍️',
                    ),
                  )
                : _errorMessage.isNotEmpty
                ? AiErrorWidget(
                    errorMessage: _errorMessage,
                    onRetry: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      _generateSummary();
                    },
                  )
                : _buildColorfulView(),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _modelChip('Flash (Cepat)', 'gemini-flash-latest'),
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
      onPressed: () => _switchModel(modelId),
      backgroundColor: isSelected ? AppColors.primaryTeal : Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primaryTeal : Colors.grey.shade300,
      ),
      avatar: isBusy
          ? const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.orange,
            )
          : null,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildColorfulView() {
    final summary = _data!['summary'] as List<dynamic>? ?? [];
    final glossary = _data!['glossary'] as List<dynamic>? ?? [];
    final flashcards = _data!['flashcards'] as List<dynamic>? ?? [];
    final quiz = _data!['practiceQuestions'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(_data!['title'] ?? widget.title),
          const SizedBox(height: 24),

          _buildSectionHeader('📖 Rangkuman Inti', Colors.orangeAccent),
          ...summary.map((point) => _buildSummaryPoint(point.toString())),
          const SizedBox(height: 24),

          if (flashcards.isNotEmpty) ...[
            _buildSectionHeader('🃏 Kartu Hafalan', AppColors.zenGold),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  return _buildFlashcard(flashcards[index], index);
                },
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Tap kartu untuk membalik 🔄',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (glossary.isNotEmpty) ...[
            _buildSectionHeader('📚 Glosarium Penting', AppColors.accentBlue),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: glossary.map((g) => _buildGlossaryItem(g)).toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (quiz.isNotEmpty) ...[
            _buildSectionHeader('✍️ Latihan Soal', AppColors.primaryTeal),
            ...quiz.asMap().entries.map(
              (entry) => _buildQuizCard(entry.value, entry.key),
            ),
          ],

          const SizedBox(height: 32),
          _buildFlashcardButton(flashcards),
          const SizedBox(height: 12),
          _buildActionBtn(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFlashcardButton(List<dynamic> flashcards) {
    if (flashcards.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.zenGold, width: 2),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          final List<Map<String, String>> formattedCards = flashcards
              .map(
                (f) => {
                  'question': (f['q'] ?? f['question'] ?? '').toString(),
                  'answer': (f['a'] ?? f['answer'] ?? '').toString(),
                },
              )
              .toList();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FlashcardScreen(initialCards: formattedCards),
            ),
          );
        },
        icon: const Icon(Icons.style_rounded, color: AppColors.zenGold),
        label: const Text(
          'Mainkan Flashcard Ini 🃏',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.zenGold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E6F54), Color(0xFF1B4332)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPoint(String point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✅', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(Map<String, dynamic> card, int index) {
    bool isFlipped = _flippedCards[index] ?? false;
    return FlipCard(
      isFlipped: isFlipped,
      onTap: () => setState(() => _flippedCards[index] = !isFlipped),
      front: _buildSummaryCardSide(card['q'] ?? '', isFlipped: false),
      back: _buildSummaryCardSide(card['a'] ?? '', isFlipped: true),
    );
  }

  Widget _buildSummaryCardSide(String text, {required bool isFlipped}) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFlipped
              ? [AppColors.zenGold, const Color(0xFFB88E4F)]
              : [Colors.white, const Color(0xFFF9F9F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isFlipped ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildGlossaryItem(Map<String, dynamic> g) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            g['term'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accentBlue,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            g['definition'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quizData, int qIndex) {
    int? selected = _selectedAnswers[qIndex];
    int correctIndex = quizData['a'] ?? -1;
    bool isAnswered = selected != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${qIndex + 1}: ${quizData['q'] ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...(quizData['options'] as List<dynamic>? ?? []).asMap().entries.map((
            optEntry,
          ) {
            int optIndex = optEntry.key;
            String optText = optEntry.value.toString();

            Color bgColor = Colors.transparent;
            Color iconColor = AppColors.primaryTeal;
            IconData icon = Icons.radio_button_off;

            if (isAnswered) {
              if (optIndex == correctIndex) {
                bgColor = Colors.green.withOpacity(0.15);
                iconColor = Colors.green;
                icon = Icons.check_circle_rounded;
              } else if (optIndex == selected) {
                bgColor = Colors.red.withOpacity(0.15);
                iconColor = Colors.red;
                icon = Icons.cancel_rounded;
              }
            } else if (selected == optIndex) {
              iconColor = AppColors.primaryTeal;
              icon = Icons.radio_button_checked;
            }

            return GestureDetector(
              onTap: isAnswered
                  ? null
                  : () => setState(() => _selectedAnswers[qIndex] = optIndex),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isAnswered && optIndex == correctIndex
                        ? Colors.green
                        : isAnswered && optIndex == selected
                        ? Colors.red
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 22, color: iconColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        optText,
                        style: TextStyle(
                          fontWeight:
                              isAnswered &&
                                  (optIndex == correctIndex ||
                                      optIndex == selected)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isAnswered
                              ? (optIndex == correctIndex
                                    ? Colors.green.shade700
                                    : optIndex == selected
                                    ? Colors.red.shade700
                                    : AppColors.textPrimary)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionBtn() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.zenGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'Saya Sudah Paham! 🔥',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
