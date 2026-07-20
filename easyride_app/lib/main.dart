import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'sensor_service.dart';
import 'api_service.dart';
import 'map_screen.dart';
import 'app_theme.dart';
import 'main_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScaffold(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState(); 
}

class _DashboardState extends State<Dashboard> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _initForegroundTask();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  void _onReceiveTaskData(Object data) {
    if (data is String) {
      ApiService.addLog(data);
    }
  }

Future<void> _initForegroundTask() async {
    await Geolocator.requestPermission();
    await FlutterForegroundTask.requestNotificationPermission();
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'easyride_tracking',
        channelName: 'EasyRide Tracking',
        channelDescription: 'Сканирование ям работает в фоне',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  void _toggleTracking() async {
    try {
      if (_isActive) {
        ApiService.addLog("Остановка службы...");
        await FlutterForegroundTask.stopService();
        setState(() => _isActive = false);
      } else {
        ApiService.addLog("Запуск службы...");
        
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
        }
        
        await FlutterForegroundTask.startService(
          notificationTitle: 'EasyRide',
          notificationText: 'Сканирование дороги активно',
          callback: startCallback,
        );
        setState(() => _isActive = true);
      }
    } catch (e) {
      ApiService.addLog("Ошибка старта: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("EasyRide MVP: Логи"),
          backgroundColor: Colors.black87,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _isActive ? "Сканирование ИДЕТ" : "Сканирование ОТКЛЮЧЕНО",
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
                      _isActive ? "Остановить" : "Поехали",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),
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
      ),
    );
  }
}