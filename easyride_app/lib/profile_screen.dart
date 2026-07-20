import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _buildHeader(),
            _buildStatsGrid(),
            _buildSectionTitle("Достижения", "Все (18)"),
            _buildBadges(),
            _buildSectionTitle("Активность · Октябрь", "28 дней"),
            _buildHeatmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            alignment: Alignment.center,
            child: const Text("АК", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          const SizedBox(height: 12),
          const Text("Алексей Козлов", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 2),
          const Text("@alex_k · Москва", style: TextStyle(fontSize: 13, color: AppColors.text3)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.warning.withValues(alpha: 0.15), AppColors.warning.withValues(alpha: 0.05)]),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                const SizedBox(width: 6),
                Text("Топ-5% сообщества", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning.withValues(alpha: 0.9))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard("147", "Ям обнаружено", "↑ +12 за неделю", isAccent: true),
              const SizedBox(width: 10),
              _buildStatCard("1,234", "Километров пройдено", "↑ +86 км"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatCard("2,840", "Очков рейтинга", "↑ +340"),
              const SizedBox(width: 10),
              _buildStatCard("12", "Подвесок спасено", "★ рейтинг 4.9"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, String trend, {bool isAccent = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAccent ? null : AppColors.surface,
          gradient: isAccent ? LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.secondary.withValues(alpha: 0.04)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
          border: Border.all(color: isAccent ? AppColors.primary.withValues(alpha: 0.15) : AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.0)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.text3, height: 1.3)),
            const SizedBox(height: 4),
            Text(trend, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String linkText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
          Text(linkText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    final badges = [
      {"icon": "🎯", "name": "Охотник\nза ямами", "color": AppColors.danger},
      {"icon": "🛡️", "name": "Спаситель\nподвесок", "color": AppColors.primary},
      {"icon": "⚡", "name": "Скоростной\nрежим", "color": AppColors.warning},
      {"icon": "🌃", "name": "Ночной\nдозор", "color": AppColors.secondary},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: badges.map((b) {
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: (b["color"] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(b["icon"] as String, style: const TextStyle(fontSize: 20)),
                ),
                Text(
                  b["name"] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.2),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeatmap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ПН", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("ВТ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("СР", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("ЧТ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("ПТ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("СБ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
              Text("ВС", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 28, // 4 недели
            itemBuilder: (context, index) {
              // Имитация разной активности
              double intensity = 0.05;
              if (index % 7 == 2) intensity = 0.2;
              if (index % 5 == 0) intensity = 0.4;
              if (index == 12 || index == 18) intensity = 0.8;
              if (index == 10 || index == 20) intensity = 0.0;

              return Container(
                decoration: BoxDecoration(
                  color: intensity == 0 ? AppColors.surface : AppColors.primary.withValues(alpha: intensity),
                  borderRadius: BorderRadius.circular(4),
                  border: intensity == 0 ? Border.all(color: AppColors.border) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}