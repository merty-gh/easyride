import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _loadBumps(); // Загружаем ямы при открытии экрана
  }

  void _loadBumps() async {
    final bumps = await ApiService.getBumps();
    setState(() {
      _markers = bumps.map((b) {
        // Простая классификация ям для MVP (цветовая градация)
        Color markerColor = Colors.green;
        double force = b['bump_force'];
        
        if (force > 25) {
          markerColor = Colors.red;
        } else if (force > 15) {
          markerColor = Colors.orange;
        }

        return Marker(
          point: LatLng(b['lat'], b['lon']),
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: markerColor, size: 40),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Карта ям"), backgroundColor: Colors.black87),
      body: FlutterMap(
        options: const MapOptions(
          // Координаты центра Москвы по умолчанию, потом сделаем центрирование по GPS
          initialCenter: LatLng(55.751244, 37.618423), 
          initialZoom: 11.0,
        ),
        children: [
          TileLayer(
            // Подключаем бесплатные тайлы OpenStreetMap
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.easyride.app',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: _loadBumps,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}