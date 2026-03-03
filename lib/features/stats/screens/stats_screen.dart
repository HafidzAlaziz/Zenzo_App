import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/widgets/study_chart.dart';
import '../../../core/widgets/count_up_text.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistik Belajar'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListenableBuilder(
        listenable: StatisticsService(),
        builder: (context, _) {
          final stats = StatisticsService();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewHeader(context, stats),
                const SizedBox(height: 32),
                Text(
                  'Detail Aktivitas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityList(stats),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewHeader(BuildContext context, StatisticsService stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.zenGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Waktu Belajar',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          CountUpText(
            targetValue: stats.studyTimeMinutes,
            suffix: ' Menit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          StudyLineChart(
            data: stats.weeklyData,
            height: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          const Text(
            'Materi yang Dirangkum',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          StudyLineChart(
            data: [1, 2, 1, 3, 2, 4, stats.materialsSummarized % 5 + 1],
            height: 80,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLargeStat('Kuis', stats.quizzesCompleted),
              _buildLargeStat('Kartu', stats.flashcardsPlayed),
              _buildLargeStat('Waktu', stats.studyTimeMinutes, suffix: 'm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStat(String label, int value, {String suffix = ''}) {
    return Column(
      children: [
        CountUpText(
          targetValue: value,
          suffix: suffix,
          duration: const Duration(milliseconds: 2000),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActivityList(StatisticsService stats) {
    return Column(
      children: [
        _buildActivityTile(
          'Latihan Soal',
          'Selesaikan lebih banyak kuis untuk menguji pemahaman.',
          '${stats.quizzesCompleted} Kuis',
          Icons.quiz_rounded,
          const Color(0xFF6C63FF),
        ),
        _buildActivityTile(
          'Flashcard AI',
          'Hafalkan poin penting dengan kartu pintar.',
          '${stats.flashcardsPlayed} Kartu',
          Icons.style_rounded,
          const Color(0xFFD1A15E),
        ),
        _buildActivityTile(
          'Ringkasan Materi',
          'Materi yang sudah dirangkum oleh AI.',
          '${stats.materialsSummarized} Materi',
          Icons.summarize_rounded,
          const Color(0xFF1B4332),
        ),
      ],
    );
  }

  Widget _buildActivityTile(
    String title,
    String subtitle,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
