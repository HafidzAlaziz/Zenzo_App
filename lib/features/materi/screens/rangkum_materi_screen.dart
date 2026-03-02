import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/gemini_service.dart';
import 'ai_summary_screen.dart';
import '../../../core/services/learning_data_service.dart';

class RangkumMateriScreen extends StatefulWidget {
  const RangkumMateriScreen({super.key});

  @override
  State<RangkumMateriScreen> createState() => _RangkumMateriScreenState();
}

class _RangkumMateriScreenState extends State<RangkumMateriScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedModel = 'gemini-flash-latest';

  void _navigateToSummary(String title, String content) {
    LearningDataService().addMaterial(content); // Simpan ke histori belajar
    _controller.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiSummaryScreen(
          title: title,
          content: content,
          initialModel: _selectedModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rangkum Materi AI'),
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
              'Rangkum Teks Anda ✨',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Tempel materi pelajaran di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Model Selection Header
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

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _navigateToSummary('Rangkuman Kustom', _controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Mulai Rangkum AI'),
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
