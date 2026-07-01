import 'package:flutter/material.dart';
import 'sensor_service.dart';
import 'api_service.dart';
import 'map_screen.dart';

void main() {
  runApp(const MyApp()); // Исправлена ошибка с const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Исправлено предупреждение о ключе

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState(); // Исправлен модификатор
}

class _DashboardState extends State<Dashboard> {
  final SensorService _sensorService = SensorService();
  bool _isActive = false;

  void _toggleTracking() {
    setState(() {
      _isActive = !_isActive;
    });
    if (_isActive) {
      _sensorService.startMonitoring();
    } else {
      _sensorService.stopMonitoring();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EasyRide MVP: Логи"),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          // Блок с кнопкой (Верхняя часть)
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  _isActive ? "Сканирование дороги ИДЕТ" : "Сканирование ОТКЛЮЧЕНО",
                  style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: _isActive ? Colors.green : Colors.red),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    backgroundColor: _isActive ? Colors.red : Colors.green,
                  ),
                  onPressed: _toggleTracking,
                  child: Text(
                    _isActive ? "Остановить" : "Поехали!",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15), // Отступ
                // НОВАЯ КНОПКА ДЛЯ КАРТЫ
                OutlinedButton.icon(
                  icon: const Icon(Icons.map, color: Colors.blueAccent),
                  label: const Text("Открыть карту", style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
                  },
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),
          // Блок с логами (Нижняя часть)
          Expanded(
            child: Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(10),
              child: ValueListenableBuilder<List<String>>(
                valueListenable: ApiService.logs,
                builder: (context, logs, child) {
                  return ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          logs[index],
                          style: const TextStyle(
                            color: Colors.greenAccent, 
                            fontFamily: 'monospace',
                            fontSize: 13
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}