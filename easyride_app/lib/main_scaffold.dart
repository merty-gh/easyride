import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets/glass_panel.dart';
import 'map_screen.dart';
import 'list_screen.dart';
import 'detect_screen.dart';
import 'profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Список наших экранов
  final List<Widget> _screens = [
    const MapScreen(),
    const ListScreen(),
    const DetectScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // ВАЖНО: Карта будет заезжать под прозрачную панель навигации
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return GlassPanel(
      height: 88,
      blur: 28.0,
      opacity: 0.95,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavItem(0, Icons.map_outlined, "Карта"),
          _buildNavItem(1, Icons.format_list_bulleted_rounded, "Список"),
          _buildCenterItem(2), // Центральная кнопка детекции
          _buildNavItem(3, Icons.person_outline, "Профиль"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 24, 
              color: isActive ? AppColors.primary : AppColors.text3
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterItem(int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Transform.translate(
        offset: const Offset(0, -24), // Поднимаем кнопку вверх, как в дизайне
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF1D4ED8)], // Синий градиент
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.adjust, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}