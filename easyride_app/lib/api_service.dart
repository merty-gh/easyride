import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String apiUrl = 'http://64.188.74.72:8000/api/v1/telemetry'; 
  
  static ValueNotifier<List<String>> logs = ValueNotifier([]);

  static void addLog(String message) {
    final time = DateTime.now().toString().split(' ').last.substring(0, 8);
    logs.value = ["[$time] $message", ...logs.value]; 
  }

  static Future<void> sendBump(double lat, double lon, double speed, double force) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 'test_user_01',
          'latitude': lat,
          'longitude': lon,
          'speed_kmh': speed,
          'bump_force': force,
        }),
      );
      
      if (response.statusCode == 200) {
        addLog("УСПЕХ! Сила: ${force.toStringAsFixed(1)}, Скорость: ${speed.toStringAsFixed(1)} км/ч");
      } else {
        addLog("Ошибка сервера: Код ${response.statusCode}");
      }
    } catch (e) {
      addLog("Ошибка сети: Нет связи с сервером");
    }
  }

  static Future<List<dynamic>> getBumps() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Ошибка загрузки карты: $e");
    }
    return [];
  }
}