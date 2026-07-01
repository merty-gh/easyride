import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'api_service.dart';

class SensorService {
  bool isMonitoring = false;
  
  // Порог срабатывания (надо будет менять по результатам твоих заездов)
  final double bumpThreshold = 15.0; 

  void startMonitoring() async {
    isMonitoring = true;
    ApiService.addLog("🚀 Мониторинг запущен. Ждем ямы...");
    
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ApiService.addLog("❌ Ошибка: Нет доступа к GPS!");
      return;
    }

    userAccelerometerEventStream().listen((UserAccelerometerEvent event) async {
      if (!isMonitoring) return;

      double force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > bumpThreshold) {
        // Блокируем новые срабатывания, пока обрабатываем эту яму
        isMonitoring = false; 

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
        );
        
        double speedKmh = position.speed * 3.6; 

        if (speedKmh > 20.0) {
          ApiService.addLog("⚡ УДАР (${force.toStringAsFixed(1)}). Отправка...");
          await ApiService.sendBump(position.latitude, position.longitude, speedKmh, force);
        } else {
          ApiService.addLog("⚠️ Удар (${force.toStringAsFixed(1)}), но скорость мала (${speedKmh.toStringAsFixed(1)})");
        }

        // Ждем 2 секунды перед тем, как ловить следующую яму
        Future.delayed(const Duration(seconds: 2), () {
          isMonitoring = true;
        });
      }
    });
  }

  void stopMonitoring() {
    isMonitoring = false;
    ApiService.addLog("🛑 Мониторинг остановлен");
  }
}