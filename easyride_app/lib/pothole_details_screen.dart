import 'package:flutter/material.dart';
import 'app_theme.dart';

class PotholeDetailsScreen extends StatelessWidget {
  const PotholeDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Большая яма на дороге", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.3)),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.text3),
                      SizedBox(width: 6),
                      Expanded(child: Text("Ленинградский пр-т, 78 · 200 м от АЗС", style: TextStyle(fontSize: 13, color: AppColors.text3))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoGrid(),
                  const SizedBox(height: 16),
                  _buildMiniMap(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                  _buildCommentsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: AppColors.text, size: 20),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.share_outlined, color: AppColors.text, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Заглушка для фото
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFF3F4F6), Color(0xFFE5E7EB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: const Icon(Icons.broken_image_outlined, size: 100, color: AppColors.border),
            ),
            // Градиент для плавного перехода
            Positioned(
              bottom: 0, left: 0, right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.bg.withValues(alpha: 0), AppColors.bg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
            ),
            // Точки пагинации фото
            Positioned(
              bottom: 20, left: 0, right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 20, height: 6, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 6),
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), shape: BoxShape.circle)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _buildInfoItem("Размер", "L", AppColors.danger),
        const SizedBox(width: 8),
        _buildInfoItem("Глубина", "~15 см", AppColors.warning),
        const SizedBox(width: 8),
        _buildInfoItem("Подтвердили", "12", AppColors.text),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.text3, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.map, size: 80, color: AppColors.border),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.danger,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: AppColors.danger.withValues(alpha: 0.4), blurRadius: 12)],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            _buildActionBtn(Icons.navigation_outlined, "Маршрут", AppColors.primary),
            const SizedBox(width: 8),
            _buildActionBtn(Icons.check_circle_outline, "Подтвердить", AppColors.secondary),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionBtn(Icons.build_circle_outlined, "Починили", AppColors.warning),
            const SizedBox(width: 8),
            _buildActionBtn(Icons.share_outlined, "Поделиться", const Color(0xFFA855F7)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.2))),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Комментарии", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text("24", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 12),
          _buildComment("МК", "Михаил К.", "2ч назад", "Подтверждаю, яма стала ещё глубже после дождя! 💦", const [AppColors.warning, AppColors.danger]),
          const Divider(color: AppColors.border),
          _buildComment("ОП", "Ольга П.", "5ч назад", "Проезжала сегодня утром — пока цела, но объезжать лучше слева.", const [AppColors.secondary, AppColors.primary]),
        ],
      ),
    );
  }

  Widget _buildComment(String initials, String name, String time, String text, List<Color> colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: colors)),
            alignment: Alignment.center,
            child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(width: 6),
                    Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.text3)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(fontSize: 12, color: AppColors.text2, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}