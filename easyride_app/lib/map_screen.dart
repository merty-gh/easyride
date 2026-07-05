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
  List<CircleMarker> _roadSegments = [];
  List<Marker> _unconfirmedMarkers = [];

  @override
  void initState() {
    super.initState();
    _loadBumps();
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

      Color roadColor = Colors.lightGreenAccent; 
      double radius = 10.0; 

      if (force > 30) {
        roadColor = Colors.redAccent.withValues(alpha: 0.7); // Исправлено здесь
        radius = 15.0;
      } else if (force > 20) {
        roadColor = Colors.orangeAccent.withValues(alpha: 0.7); // Исправлено здесь
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
    return Scaffold(
      appBar: AppBar(title: const Text("Состояние дорог"), backgroundColor: Colors.black87),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(55.751244, 37.618423), 
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.easyride.app',
          ),
          CircleLayer(circles: _roadSegments),
          MarkerLayer(markers: _unconfirmedMarkers),
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