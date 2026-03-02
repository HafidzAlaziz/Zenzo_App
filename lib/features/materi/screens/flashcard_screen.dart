import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/learning_data_service.dart';
import '../../../core/widgets/writing_animation.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<Map<String, String>> _flashcards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;

  // New controls
  double _cardCount = 5;
  String _selectedModel = 'gemini-flash-latest';

  Future<void> _generateFlashcards() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Save to history
    LearningDataService().addMaterial(_controller.text);

    final cards = await GeminiService.generateFlashcards(
      _controller.text,
      count: _cardCount.toInt(),
      model: _selectedModel,
    );

    if (mounted) {
      setState(() {
        _flashcards = cards.isEmpty
            ? [
                {
                  'question': 'Apa itu Fotosintesis?',
                  'answer':
                      'Proses tumbuhan hijau mengubah energi cahaya menjadi energi kimia (makanan).',
                },
                {
                  'question': 'Sebutkan 3 hukum Newton!',
                  'answer': '1. Inersia, 2. F=ma, 3. Aksi-Reaksi.',
                },
                {
                  'question': 'Ibu kota Indonesia?',
                  'answer': 'Jakarta (saat ini) / Nusantara (IKN).',
                },
                {
                  'question': 'Siapa penemu lampu pijar?',
                  'answer': 'Thomas Alva Edison.',
                },
                {
                  'question': 'Apa itu Pancasila?',
                  'answer': 'Dasar negara dan ideologi bangsa Indonesia.',
                },
              ]
            : cards;
        _isLoading = false;
        _currentIndex = 0;
        _showAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Main Flashcard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _flashcards.isEmpty ? _buildInputView() : _buildFlashcardView(),
      ),
    );
  }

  Widget _buildInputView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 64,
            color: AppColors.zenGold,
          ),
          const SizedBox(height: 16),
          const Text(
            'Buat Flashcard dengan AI',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tulis atau tempel materi di sini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Model Selection
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pilih Model AI:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _modelChip('Flash', 'gemini-flash-latest'),
              const SizedBox(width: 12),
              _modelChip('Pro', 'gemini-1.5-pro-latest'),
            ],
          ),

          const SizedBox(height: 24),

          // Card Count Selection
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jumlah Kartu: ${_cardCount.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Slider(
            value: _cardCount,
            min: 3,
            max: 10,
            divisions: 7,
            label: _cardCount.round().toString(),
            activeColor: AppColors.zenGold,
            onChanged: (value) => setState(() => _cardCount = value),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _generateFlashcards,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.zenGold,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Generate Kartu ✨'),
          ),
          if (_isLoading) ...[
            const SizedBox(height: 32),
            const WritingAnimation(text: 'AI sedang menulis kartu hafalan...'),
          ],
        ],
      ),
    );
  }

  Widget _modelChip(String label, String modelId) {
    bool isSelected = _selectedModel == modelId;
    String? status = GeminiService.getModelStatus(modelId);
    bool isBusy = status != null;

    return Expanded(
      child: ActionChip(
        onPressed: () => setState(() => _selectedModel = modelId),
        backgroundColor: isSelected ? AppColors.zenGold : Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.zenGold : Colors.grey.shade300,
        ),
        avatar: isBusy
            ? const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Colors.orange,
              )
            : null,
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlashcardView() {
    final card = _flashcards[_currentIndex];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _flashcards.length,
          backgroundColor: AppColors.zenGold.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation(AppColors.zenGold),
        ),
        const SizedBox(height: 12),
        Text('Kartu ${_currentIndex + 1} dari ${_flashcards.length}'),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _showAnswer = !_showAnswer),
          child: Container(
            height: 350,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.zenGold.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  _showAnswer ? card['answer']! : card['question']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _showAnswer
                        ? AppColors.primaryTeal
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap kartu untuk melihat jawaban',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentIndex > 0
                  ? () => setState(() {
                      _currentIndex--;
                      _showAnswer = false;
                    })
                  : null,
              icon: const Icon(Icons.arrow_back_ios_rounded),
            ),
            ElevatedButton(
              onPressed: () {
                if (_currentIndex < _flashcards.length - 1) {
                  setState(() {
                    _currentIndex++;
                    _showAnswer = false;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _currentIndex < _flashcards.length - 1 ? 'Lanjut' : 'Tutup',
              ),
            ),
            IconButton(
              onPressed: _currentIndex < _flashcards.length - 1
                  ? () => setState(() {
                      _currentIndex++;
                      _showAnswer = false;
                    })
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
