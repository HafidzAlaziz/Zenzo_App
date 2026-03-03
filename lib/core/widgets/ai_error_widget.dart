import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AiErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String? title;

  const AiErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    bool isForbidden = errorMessage.contains('403');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isForbidden ? Icons.security_rounded : Icons.cloud_off_rounded,
              size: 80,
              color: isForbidden ? AppColors.zenGold : AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              title ??
                  (isForbidden
                      ? 'Akses Ditolak 🛡️'
                      : 'Server Sedang Penuh! 🚧'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _formatErrorMessage(errorMessage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatErrorMessage(String msg) {
    if (msg.contains('403')) {
      return 'API Key Anda terdeteksi bocor. Demi keamanan, Google menonaktifkan kunci ini. Silakan ganti dengan API Key baru di gemini_service.dart.';
    }
    if (msg.contains('503') || msg.contains('429')) {
      return 'AI sedang sangat sibuk memproses banyak permintaan. Tunggu sebentar lalu coba lagi ya!';
    }
    return 'Terjadi kesalahan teknis. Jangan khawatir, tim kami sedang mengeceknya. ($msg)';
  }
}
