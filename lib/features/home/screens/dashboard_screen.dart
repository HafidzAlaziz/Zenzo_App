import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../materi/screens/materi_screen.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../quiz/screens/latihan_soal_input_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../target/screens/quest_screen.dart';
import '../../materi/screens/flashcard_screen.dart';
import '../../materi/screens/rangkum_materi_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const MateriScreen(),
    const Center(child: Text('Halaman Kesehatan')),
    const Center(child: Text('Halaman Profil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppColors.primaryTeal,
          unselectedItemColor: AppColors.textSecondary,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Materi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Kesehatan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 18) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  String _getMotivation() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Mulai hari dengan semangat belajar!';
    if (hour < 15) return 'Tetap fokus, kamu sudah hebat!';
    if (hour < 18) return 'Sore yang produktif itu menyenangkan!';
    return 'Belajar malam? Kamu luar biasa! ✨';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, textTheme),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthCard(textTheme),
                  const SizedBox(height: 20),
                  _buildStreakCard(textTheme),
                  const SizedBox(height: 24),
                  Text(
                    'Menu Utama',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildMenuGrid(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rangkuman Terkini',
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            _buildMateriScroll(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D7A5A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Halo, Pelajar! 👋',
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMotivation(),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 26,
              backgroundColor: Color(0xFF4A7BAF),
              child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF4A7BAF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Kesehatan',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHealthStat(
                'Tidur',
                '7 Jam',
                Icons.bedtime_rounded,
                const Color(0xFF90E0EF),
              ),
              _buildDivider(),
              _buildHealthStat(
                'Langkah',
                '3.200',
                Icons.directions_walk_rounded,
                const Color(0xFF95D5B2),
              ),
              _buildDivider(),
              _buildHealthStat(
                'Fokus',
                '2 Jam',
                Icons.psychology_rounded,
                const Color(0xFFFFD166),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF95D5B2),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 48, color: Colors.white.withOpacity(0.2));

  Widget _buildStreakCard(TextTheme textTheme) {
    final days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final completed = [true, true, true, true, false, false, false];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFAA40)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak Belajar',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '4 hari berturut-turut 🔥',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  '🏆 4',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: completed[i]
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFFFAA40)],
                            )
                          : null,
                      color: completed[i] ? null : const Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        days[i],
                        style: TextStyle(
                          color: completed[i]
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (completed[i])
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 10,
                      color: Color(0xFFFF6B35),
                    )
                  else
                    const SizedBox(height: 10),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      _MenuData(
        label: 'Rangkum\nMateri',
        icon: Icons.summarize_rounded,
        color: const Color(0xFF1B4332),
        gradientColors: const [Color(0xFF1B4332), Color(0xFF2D7A5A)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RangkumMateriScreen()),
        ),
      ),
      _MenuData(
        label: 'Main\nFlashcard',
        icon: Icons.style_rounded,
        color: const Color(0xFFD1A15E),
        gradientColors: const [Color(0xFFD1A15E), Color(0xFFFF9A3C)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FlashcardScreen()),
        ),
      ),
      _MenuData(
        label: 'Kuis\nHarian',
        icon: Icons.quiz_rounded,
        color: const Color(0xFF6C63FF),
        gradientColors: const [Color(0xFF6C63FF), Color(0xFF9B59B6)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        ),
      ),
      _MenuData(
        label: 'Latihan\nSoal',
        icon: Icons.assignment_rounded,
        color: const Color(0xFF43AA8B),
        gradientColors: const [Color(0xFF43AA8B), Color(0xFF1B4332)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LatihanSoalInputScreen()),
        ),
      ),
      _MenuData(
        label: 'Quest',
        icon: Icons.military_tech_rounded,
        color: const Color(0xFFFF6B6B),
        gradientColors: const [Color(0xFFFF6B6B), Color(0xFFFFAA40)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuestScreen()),
        ),
      ),
      _MenuData(
        label: 'Statistik',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFF4A7BAF),
        gradientColors: const [Color(0xFF4A7BAF), Color(0xFF6C63FF)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        ),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) => _buildMenuCard(menus[index]),
    );
  }

  Widget _buildMenuCard(_MenuData menu) {
    return GestureDetector(
      onTap: menu.onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: menu.color.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: menu.gradientColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(menu.icon, color: Colors.white, size: 22),
            ),
            Text(
              menu.label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriScroll() {
    final materiList = [
      _MateriData(
        subject: 'Matematika',
        topic: 'Integral & Turunan',
        progress: 0.75,
        color: const Color(0xFF6C63FF),
      ),
      _MateriData(
        subject: 'Fisika',
        topic: 'Gerak Lurus Berubah',
        progress: 0.50,
        color: const Color(0xFF43AA8B),
      ),
      _MateriData(
        subject: 'Kimia',
        topic: 'Ikatan Kimia',
        progress: 0.30,
        color: const Color(0xFFFF6B6B),
      ),
      _MateriData(
        subject: 'Biologi',
        topic: 'Sistem Pencernaan',
        progress: 0.90,
        color: const Color(0xFFD1A15E),
      ),
    ];
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: materiList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => _buildMateriCard(materiList[index]),
      ),
    );
  }

  Widget _buildMateriCard(_MateriData materi) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: materi.color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: materi.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              materi.subject,
              style: TextStyle(
                color: materi.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            materi.topic,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                '${(materi.progress * 100).toInt()}%',
                style: TextStyle(
                  color: materi.color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              value: materi.progress,
              backgroundColor: materi.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(materi.color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuData {
  final String label;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  _MenuData({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });
}

class _MateriData {
  final String subject;
  final String topic;
  final double progress;
  final Color color;
  _MateriData({
    required this.subject,
    required this.topic,
    required this.progress,
    required this.color,
  });
}
