import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String apiUrl = 'http://64.188.74.72:8000/api/v1/telemetry'; 
  
  static ValueNotifier<List<String>> logs = ValueNotifier([]);

  // Этот метод вызываем ТОЛЬКО из главного экрана (UI)
  static void addLog(String message) {
    final time = DateTime.now().toString().split(' ').last.substring(0, 8);
    logs.value = ["[$time] $message", ...logs.value]; 
  }

  // Метод только отправляет данные и возвращает успех/ошибку (БЕЗ логов)
  static Future<bool> sendBump(double lat, double lon, double speed, double force) async {
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
      return response.statusCode == 200;
    } catch (e) {
      return false;
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