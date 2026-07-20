import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'pothole_details_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  int _activeFilterIndex = 0;
  final List<String> _filters = ["Сегодня · 8", "Неделя", "Месяц", "Все"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false, // Чтобы контент заезжал под прозрачный BottomNav
        child: ListView(
          padding: const EdgeInsets.only(bottom: 120), // Отступ под BottomNav
          children: [
            _buildHeader(),
            _buildStatBanner(),
            _buildFilters(),

            // Заглушки карточек ям
            _buildPotholeCard(
              address: "Ленинградский пр-т, 78",
              time: "Сегодня, 14:32",
              distance: "2.4 км",
              size: "Большая",
              confirms: 12,
              isBig: true,
            ),
            _buildPotholeCard(
              address: "ул. Тверская, 15",
              time: "Сегодня, 12:18",
              distance: "0.8 км",
              size: "Средняя",
              confirms: 7,
              isMedium: true,
            ),
            _buildPotholeCard(
              address: "Садовое кольцо, 42",
              time: "Сегодня, 09:45",
              distance: "5.1 км",
              size: "Малая",
              confirms: 3,
            ),
            _buildPotholeCard(
              address: "Кутузовский пр-т, 26",
              time: "Вчера, 18:22",
              distance: "3.7 км",
              size: "Большая",
              confirms: 18,
              isBig: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Обнаруженные ямы",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Ваша карта дорожных проблем",
            style: TextStyle(fontSize: 13, color: AppColors.text2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBanner() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.text,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: "Вы обнаружили "),
                  TextSpan(
                    text: "47 ям",
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " и спасли "),
                  TextSpan(
                    text: "12 подвесок",
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " 🛡️"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isActive = _activeFilterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _activeFilterIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                _filters[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.primary : AppColors.text2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPotholeCard({
    required String address,
    required String time,
    required String distance,
    required String size,
    required int confirms,
    bool isBig = false,
    bool isMedium = false,
  }) {
    // Выбор цвета в зависимости от размера
    Color tagBg = AppColors.secondary.withValues(alpha: 0.15);
    Color tagText = AppColors.secondary;
    if (isBig) {
      tagBg = AppColors.danger.withValues(alpha: 0.15);
      tagText = AppColors.danger;
    } else if (isMedium) {
      tagBg = const Color(0xFFFB923C).withValues(alpha: 0.15); // Orange
      tagText = const Color(0xFFFB923C);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PotholeDetailsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Заглушка для фото (SVG из дизайна)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.broken_image_rounded,
                color: AppColors.text2,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text2,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "•",
                          style: TextStyle(color: AppColors.text3),
                        ),
                      ),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Действия и теги
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "● ${size.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: tagText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.secondary,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$confirms",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.navigation_outlined,
                              color: AppColors.primary,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "Маршрут",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
