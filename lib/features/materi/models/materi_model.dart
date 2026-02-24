import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class Materi {
  final String title;
  final String category;
  final IconData icon;
  final double progress; // 0.0 to 1.0
  final Color themeColor;
  final String content;

  Materi({
    required this.title,
    required this.category,
    required this.icon,
    this.progress = 0.0,
    required this.themeColor,
    required this.content,
  });
}

final List<Materi> dummyMateri = [
  Materi(
    title: 'Dasar-Dasar Biologi',
    category: 'Biologi',
    icon: Icons.biotech_rounded,
    progress: 0.65,
    themeColor: AppColors.primaryTeal,
    content: 'Biologi adalah ilmu yang mempelajari tentang makhluk hidup...',
  ),
  Materi(
    title: 'Kimia Organik 101',
    category: 'Kimia',
    icon: Icons.science_rounded,
    progress: 0.30,
    themeColor: AppColors.accentBlue,
    content:
        'Kimia organik berfokus pada struktur, sifat, dan reaksi senyawa organik...',
  ),
  Materi(
    title: 'Gizi dan Nutrisi',
    category: 'Kesehatan',
    icon: Icons.apple_rounded,
    progress: 0.90,
    themeColor: AppColors.zenGold,
    content: 'Nutrisi yang seimbang adalah kunci untuk gaya hidup sehat...',
  ),
  Materi(
    title: 'Anatomi Tubuh Dasar',
    category: 'Kesehatan',
    icon: Icons.accessibility_new_rounded,
    progress: 0.15,
    themeColor: AppColors.error,
    content: 'Mempelajari struktur fisik dari organisme hidup...',
  ),
];
