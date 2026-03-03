import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [_buildPodium(), const SizedBox(height: 32)],
              ),
            ),
          ),
          _buildRankList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF1B4332),
      elevation: 0,
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Rankingan Global',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D7A5A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              right: -50,
              top: -20,
              child: Icon(
                Icons.emoji_events_rounded,
                size: 200,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumItem(
          rank: 2,
          name: 'Budi S.',
          score: '2.450 XP',
          height: 140,
          color: const Color(0xFFC0C0C0),
          avatar: 'https://i.pravatar.cc/150?u=2',
        ),
        _buildPodiumItem(
          rank: 1,
          name: 'Hafidz A.',
          score: '3.120 XP',
          height: 180,
          color: const Color(0xFFFFD700),
          avatar: 'https://i.pravatar.cc/150?u=1',
          isGold: true,
        ),
        _buildPodiumItem(
          rank: 3,
          name: 'Siti R.',
          score: '1.980 XP',
          height: 120,
          color: const Color(0xFFCD7F32),
          avatar: 'https://i.pravatar.cc/150?u=3',
        ),
      ],
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required String score,
    required double height,
    required Color color,
    required String avatar,
    bool isGold = false,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: isGold ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: isGold ? 36 : 28,
                backgroundColor: AppColors.background,
                backgroundImage: NetworkImage(avatar),
              ),
            ),
            if (isGold)
              Positioned(
                top: -10,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(15 / 360),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFFFD700),
                    size: 24,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isGold ? 15 : 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            score,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.4), color.withOpacity(0.1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: isGold ? 24 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankList() {
    final otherUsers = [
      {'name': 'Rahmat K.', 'score': '1.850 XP', 'id': 4},
      {'name': 'Dewi L.', 'score': '1.720 XP', 'id': 5},
      {'name': 'Andi P.', 'score': '1.600 XP', 'id': 6},
      {'name': 'Lisa M.', 'score': '1.450 XP', 'id': 7},
      {'name': 'Bambang J.', 'score': '1.300 XP', 'id': 8},
      {'name': 'Eka W.', 'score': '1.150 XP', 'id': 9},
      {'name': 'Indra Q.', 'score': '1.000 XP', 'id': 10},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final user = otherUsers[index];
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '${index + 4}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?u=${user['id']}',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  user['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                user['score'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
        );
      }, childCount: otherUsers.length),
    );
  }
}
