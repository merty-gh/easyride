import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';
import 'app_theme.dart';
import 'widgets/glass_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<CircleMarker> _roadSegments = [];
  List<Marker> _unconfirmedMarkers = [];
  LatLng? _myLocation;

  @override
  void initState() {
    super.initState();
    _loadBumps();
    _locateUser();
  }

  Future<void> _locateUser() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
      );
      setState(() {
        _myLocation = LatLng(pos.latitude, pos.longitude);
      });
      _mapController.move(_myLocation!, 15.0);
    } catch (e) {
      debugPrint("Не удалось получить GPS: $e");
    }
  }

  void _loadBumps() async {
    final bumps = await ApiService.getBumps();
    
    List<CircleMarker> confirmedCircles = [];
    List<Marker> unconfirmed = [];

    for (var b in bumps) {
      double force = b['max_force'];
      bool isConfirmed = b['is_confirmed'];
      LatLng point = LatLng(b['lat'], b['lon']);

      if (!isConfirmed) {
        unconfirmed.add(
          Marker(
            point: point,
            width: 20,
            height: 20,
            child: const Icon(Icons.circle, color: Colors.grey, size: 15),
          )
        );
        continue;
      }

      Color roadColor = AppColors.secondary; 
      double radius = 10.0; 

      if (force > 30) {
        roadColor = AppColors.danger.withValues(alpha: 0.7); 
        radius = 15.0;
      } else if (force > 20) {
        roadColor = AppColors.warning.withValues(alpha: 0.7); 
        radius = 12.0;
      }

      confirmedCircles.add(
        CircleMarker(
          point: point,
          color: roadColor,
          borderStrokeWidth: 0,
          useRadiusInMeter: true,
          radius: radius,
        )
      );
    }

    setState(() {
      _roadSegments = confirmedCircles;
      _unconfirmedMarkers = unconfirmed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Убираем Scaffold AppBar, чтобы карта была на весь экран
    return Scaffold(
      body: Stack(
        children: [
          // 1. Сама карта (Светлый стиль Voyager)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(55.751244, 37.618423), 
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.easyride.app',
              ),
              CircleLayer(circles: _roadSegments),
              MarkerLayer(markers: [
                ..._unconfirmedMarkers,
                if (_myLocation != null)
                  Marker(
                    point: _myLocation!,
                    width: 40,
                    height: 40,
                    child: _buildUserLocationMarker(),
                  )
              ]),
            ],
          ),

          // 2. Строка поиска (Top)
          Positioned(
            top: 64,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // 3. Индикатор GPS (Right)
          Positioned(
            top: 130,
            right: 16,
            child: _buildGpsIndicator(),
          ),

          // 4. Кнопка центрирования геолокации / Мои ямы (FAB)
          Positioned(
            bottom: 230,
            right: 16,
            child: _buildFab(),
          ),

          // 5. Нижняя карточка со статусом (Bottom)
          Positioned(
            bottom: 104,
            left: 16,
            right: 16,
            child: _buildBottomCard(),
          ),
        ],
      ),
    );
  }

  // --- UI Виджеты из дизайна ---

  Widget _buildUserLocationMarker() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 4,
          )
        ]
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.text3, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Куда едем?", style: TextStyle(color: AppColors.text3, fontSize: 15)),
          ),
          const Icon(Icons.mic_none_rounded, color: AppColors.text3, size: 20),
        ],
      ),
    );
  }

  Widget _buildGpsIndicator() {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("62", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.0, letterSpacing: -1)),
          const Text("КМ/Ч", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text3, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              const Text("GPS АКТИВЕН", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.secondary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () {
        _loadBumps();
        _locateUser();
      },
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: BorderRadius.circular(14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location, color: AppColors.danger, size: 18),
            const SizedBox(width: 8),
            const Text("Где я", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.6), blurRadius: 6)]
                ),
              ),
              const SizedBox(width: 10),
              const Text("Сканирование дороги", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const Spacer(),
              const Text("активно", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text3)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatItem("24", "ЯМ РЯДОМ", AppColors.danger),
              const SizedBox(width: 8),
              _buildStatItem("3.2", "КМ ПРОЙДЕНО", AppColors.secondary),
              const SizedBox(width: 8),
              _buildStatItem("+120", "ОЧКОВ", AppColors.primary),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5, height: 1.0)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.text3, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}