import 'dart:async';
import 'dart:math';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SensorTaskHandler());
}

class SensorTaskHandler extends TaskHandler {
  StreamSubscription? _accelSubscription;
  bool isMonitoring = true;
  final double bumpThreshold = 7.0; // Порог для теста

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    FlutterForegroundTask.sendDataToMain("Фоновый мониторинг запущен...");

    _accelSubscription = userAccelerometerEventStream().listen((event) async {
      if (!isMonitoring) return;

      double force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > bumpThreshold) {
        isMonitoring = false; 

        try {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
          );
          
          double speedKmh = position.speed * 3.6;

          if (speedKmh >= 0.0) { // 0.0 для теста "на столе"
            FlutterForegroundTask.sendDataToMain("УДАР (${force.toStringAsFixed(1)}). Отправка...");
            
            // Отправляем на сервер
            bool success = await ApiService.sendBump(position.latitude, position.longitude, speedKmh, force);
            
            // Передаем статус на экран безопасно
            if (success) {
              FlutterForegroundTask.sendDataToMain("УСПЕХ! Данные на сервере.");
            } else {
              FlutterForegroundTask.sendDataToMain("Ошибка сети/сервера.");
            }
          } else {
            FlutterForegroundTask.sendDataToMain("Удар, но скорость мала: ${speedKmh.toStringAsFixed(1)} км/ч");
          }
        } catch (e) {
          FlutterForegroundTask.sendDataToMain("Ошибка GPS в фоне: $e");
        }

        Future.delayed(const Duration(seconds: 2), () {
          isMonitoring = true;
        });
      }
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTaskDestroyed) async {
    await _accelSubscription?.cancel();
    FlutterForegroundTask.sendDataToMain("Фоновый мониторинг остановлен");
  }
}