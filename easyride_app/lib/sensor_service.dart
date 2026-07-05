import 'dart:async';
import 'dart:math';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'api_service.dart';

// Точка входа для фонового процесса
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SensorTaskHandler());
}

class SensorTaskHandler extends TaskHandler {
  StreamSubscription? _accelSubscription;
  bool isMonitoring = true;
  final double bumpThreshold = 15.0; // Порог ямы

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    // Отправляем сообщение из фона в главный экран приложения
    FlutterForegroundTask.sendDataToMain("Фоновый мониторинг запущен...");

    _accelSubscription = userAccelerometerEventStream().listen((event) async {
      if (!isMonitoring) return;

      double force = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (force > bumpThreshold) {
        isMonitoring = false; // Блокируем сенсор на время отправки ямы

        try {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high)
          );
          
          double speedKmh = position.speed * 3.6;

          if (speedKmh > 20.0) {
            FlutterForegroundTask.sendDataToMain("УДАР (${force.toStringAsFixed(1)}). Отправка...");
            // Отправляем на сервер прямо из фонового режима
            await ApiService.sendBump(position.latitude, position.longitude, speedKmh, force);
          } else {
            FlutterForegroundTask.sendDataToMain("Удар, но скорость мала: ${speedKmh.toStringAsFixed(1)} км/ч");
          }
        } catch (e) {
          FlutterForegroundTask.sendDataToMain("Ошибка GPS в фоне: $e");
        }

        // Ждем 2 секунды перед тем, как ловить следующую яму
        Future.delayed(const Duration(seconds: 2), () {
          isMonitoring = true;
        });
      }
    });
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    // Вызывается по таймеру, нам тут ничего делать не нужно
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await _accelSubscription?.cancel();
    FlutterForegroundTask.sendDataToMain("Фоновый мониторинг остановлен");
  }
}