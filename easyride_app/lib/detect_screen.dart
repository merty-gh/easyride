import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'main.dart';

class DetectScreen extends StatelessWidget {
  const DetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildSpeedometer(),
            _buildWaveform(),
            _buildMiniMap(),
            _buildAlert(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Детекция", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text("Сканирование активно", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.bug_report_rounded, color: AppColors.text3),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard()));
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedometer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF475569)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              "62",
              style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -3, height: 1.0),
            ),
          ),
          const SizedBox(height: 4),
          const Text("КМ/Ч · СРЕДНЯЯ СКОРОСТЬ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 12, left: 16,
            child: Text("ВИБРАЦИИ АКСЕЛЕРОМЕТРА", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text2, letterSpacing: 1.0)),
          ),
          const Positioned(
            top: 12, right: 16,
            child: Text("2.4g", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary)),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, top: 40,
            child: CustomPaint(painter: WaveformPainter()),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF8FAFC), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Линия маршрута
          Positioned(
            top: 60, left: 20, right: 40,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)],
                ),
              ),
            ),
          ),
          // Маркер ямы
          Positioned(
            top: 48, right: 80,
            child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.danger.withValues(alpha: 0.5), blurRadius: 8)],
              ),
            ),
          ),
          // Юзер
          Positioned(
            top: 62, left: 70,
            child: Container(
              width: 16, height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 8)],
              ),
            ),
          ),
          // Подпись
          Positioned(
            bottom: 10, left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
              child: const Text("ВАШ МАРШРУТ · 2.4 КМ", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAlert() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.danger.withValues(alpha: 0.08), AppColors.danger.withValues(alpha: 0.02)]),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.warning_rounded, color: AppColors.danger),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Яма обнаружена!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                SizedBox(height: 2),
                Text("Сильная вибрация · 15 м назад", style: TextStyle(fontSize: 11, color: AppColors.text3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check, size: 18, color: Colors.white),
              label: const Text("Сохранить", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.close, size: 18, color: AppColors.text),
              label: const Text("Пропустить", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.bgSoft,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Рисуем график вибраций (имитация)
class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height / 2);
    
    // Генерируем "зигзаги"
    final List<double> points = [
      0, -2, 2, -5, 5, -10, 10, -15, 15, -20, 20, // Обычная дорога
      -35, 35, -40, 40, -30, 20, // Всплеск (Яма)
      -10, 10, -5, 5, -2, 2, 0, 0 // Снова ровно
    ];

    double stepX = size.width / points.length;
    for (int i = 0; i < points.length; i++) {
      path.lineTo(i * stepX, size.height / 2 + points[i]);
    }

    canvas.drawPath(path, paint);

    // Красная точка пика
    final dotPaint = Paint()..color = AppColors.danger;
    canvas.drawCircle(Offset(stepX * 13, size.height / 2 - 40), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}