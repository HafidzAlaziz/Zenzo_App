import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../quiz/screens/latihan_soal_input_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../target/screens/quest_screen.dart';
import '../../materi/screens/flashcard_screen.dart';
import '../../materi/screens/rangkum_materi_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/services/statistics_service.dart';
import '../../../core/widgets/study_chart.dart';
import '../../../core/widgets/count_up_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const LeaderboardScreen(),
    const ProfileScreen(),
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
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Leaderboard',
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

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome>
    with TickerProviderStateMixin {
  late AnimationController _streakController;
  late Animation<double> _streakScale;
  late AnimationController _streakDaysController;
  late List<Animation<double>> _dayAnimations;
  late AnimationController _menuController;
  late List<Animation<double>> _menuAnimations;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statsKey = GlobalKey();
  bool _statsAnimated = false;

  @override
  void initState() {
    super.initState();

    // Fire icon pop animation
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _streakScale =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
        ]).animate(
          CurvedAnimation(parent: _streakController, curve: Curves.easeOut),
        );

    // Staggered day circles animation
    _streakDaysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _dayAnimations = List.generate(7, (i) {
      final start = i / 10.0;
      final end = start + 0.3;
      return CurvedAnimation(
        parent: _streakDaysController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.elasticOut,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _streakController.forward();
        _streakDaysController.forward();
      }
    });

    // Simplified staggered menu cards animation - 2.0s for slow feel
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    const int cardCount = 6;
    _menuAnimations = List.generate(cardCount, (i) {
      // More spread out stagger
      final double start = (i * 0.15).clamp(0.0, 1.0);
      final double end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _menuController,
        curve: Interval(start, end, curve: Curves.easeOutBack),
      );
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _menuController.forward();
    });

    _scrollController.addListener(_checkStatsVisibility);
    // Initial check in case it's already visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStatsVisibility();
    });
  }

  void _checkStatsVisibility() {
    if (_statsAnimated) return;
    final statsCtx = _statsKey.currentContext;
    if (statsCtx == null) return;
    final box = statsCtx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final scrollable = Scrollable.of(statsCtx);
    final viewport = scrollable.context.findRenderObject() as RenderBox?;
    if (viewport == null) return;

    final position = box.localToGlobal(Offset.zero, ancestor: viewport);
    final viewportHeight = viewport.size.height;

    // Trigger when the stats section top is at 90% of viewport height
    if (position.dy < viewportHeight * 0.9) {
      if (mounted) {
        setState(() => _statsAnimated = true);
      }
    }
  }

  @override
  void dispose() {
    _streakController.dispose();
    _streakDaysController.dispose();
    _menuController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
        controller: _scrollController,
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
                        'Statistik Belajar',
                        style: textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatsScreen(),
                          ),
                        ),
                        child: Text(
                          'Lihat Detail',
                          style: TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(key: _statsKey, child: _buildLineChartSection()),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartSection() {
    return ListenableBuilder(
      listenable: StatisticsService(),
      builder: (context, _) {
        final stats = StatisticsService();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aktivitas Belajar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '7 Hari Terakhir',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stats.studyTimeMinutes}m',
                      style: const TextStyle(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              StudyLineChart(
                key: ValueKey(_statsAnimated),
                data: _statsAnimated
                    ? stats.weeklyData
                    : List.filled(stats.weeklyData.length, 0),
                height: 130,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat(
                    'Kuis+',
                    _statsAnimated ? stats.quizzesCompleted : 0,
                    Icons.quiz_rounded,
                    const Color(0xFF6C63FF),
                    key: ValueKey('quizzes_$_statsAnimated'),
                  ),
                  _buildMiniStat(
                    'Kartu+',
                    _statsAnimated ? stats.flashcardsPlayed : 0,
                    Icons.style_rounded,
                    const Color(0xFFD1A15E),
                    key: ValueKey('flashcards_$_statsAnimated'),
                  ),
                  _buildMiniStat(
                    'Waktu+',
                    _statsAnimated ? stats.studyTimeMinutes : 0,
                    Icons.timer_rounded,
                    AppColors.accentBlue,
                    suffix: 'm',
                    key: ValueKey('time_$_statsAnimated'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Text(
                'Materi yang Dirangkum (Harian)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              StudyLineChart(
                data: [1, 2, 1, 3, 2, 4, stats.materialsSummarized % 5 + 1],
                height: 100,
                color: const Color(0xFF1B4332),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(
    String label,
    int value,
    IconData icon,
    Color color, {
    String suffix = '',
    Key? key,
  }) {
    return Column(
      key: key,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.7), size: 16),
        const SizedBox(height: 4),
        CountUpText(
          targetValue: value,
          suffix: suffix,
          duration: const Duration(milliseconds: 2000),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
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
                7,
                'Jam',
                Icons.bedtime_rounded,
                const Color(0xFF90E0EF),
              ),
              _buildDivider(),
              _buildHealthStat(
                'Langkah',
                3200,
                'Langkah',
                Icons.directions_walk_rounded,
                const Color(0xFF95D5B2),
              ),
              _buildDivider(),
              _buildHealthStat(
                'Fokus',
                2,
                'Jam',
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
    int numericValue,
    String suffix,
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
        CountUpText(
          targetValue: numericValue,
          suffix: ' $suffix',
          duration: const Duration(milliseconds: 2000),
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
              ScaleTransition(
                scale: _streakScale,
                child: Container(
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
              return ScaleTransition(
                scale: _dayAnimations[i],
                child: Column(
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
                ),
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
      itemBuilder: (context, index) {
        final animation = _menuAnimations[index];
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: _buildMenuCard(menus[index]),
        );
      },
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
