import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import '../../quiz/screens/quiz_screen.dart';

class LatihanSoalInputScreen extends StatefulWidget {
  const LatihanSoalInputScreen({super.key});

  @override
  State<LatihanSoalInputScreen> createState() => _LatihanSoalInputScreenState();
}

class _LatihanSoalInputScreenState extends State<LatihanSoalInputScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedModel = 'gemini-flash-latest';

  void _startQuiz() {
    if (_controller.text.isEmpty) return;

    final content = _controller.text;
    _controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizScreen(customMaterial: content, initialModel: _selectedModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Latihan Soal AI 📝'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Materi Soal ✨',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tempelkan materi pelajaran, dan AI akan meramu soal latihan untukmu.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Tempel materi di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Pilih Model AI:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _modelChip('Flash (Cepat)', 'gemini-flash-latest'),
                const SizedBox(width: 12),
                _modelChip('Pro (Pintar)', 'gemini-1.5-pro-latest'),
              ],
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Buat Soal Latihan 🚀',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
}
