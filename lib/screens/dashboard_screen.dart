import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/mqtt_service.dart';
import '../../components/header.dart';
import '../../components/mqtt_config_section.dart';
import '../../components/mqtt_status.dart';
import '../../components/sensor_grid.dart';
import '../../components/gemini_analysis.dart';
import '../../components/footer.dart';
import '../../components/sensor_data_widget.dart'; // Import widget baru

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? lastErrorShown;
  String? lastSuccessShown;

  @override
  void initState() {
    super.initState();
    // Jalankan koneksi MQTT saat halaman dimuat
    Future.delayed(Duration.zero, () {
      final mqtt = Provider.of<MqttService>(context, listen: false);
      mqtt
          .connect(
            server: '172.20.10.2',
            port: 1883,
            username: 'ubuntu',
            password: 'password',
          )
          .catchError((error) {
            print('Auto-connect failed: $error');
          });
      // Subscribe otomatis dilakukan di _onConnected di mqtt_service
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final mqttService = Provider.of<MqttService>(context);

    mqttService.addListener(() {
      final error = mqttService.lastError;
      final success = mqttService.lastSuccess;

      if (error.isNotEmpty && error != lastErrorShown) {
        lastErrorShown = error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }

      if (success.isNotEmpty && success != lastSuccessShown) {
        lastSuccessShown = success;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(),
              MqttConfigSection(),
              MqttStatus(),

              // Sensor grid lama (tetap ada untuk backward compatibility)
              SensorGrid(),

              // Widget baru untuk menampilkan semua data sensor dari MQTT
              SensorDataWidget(),

              GeminiAnalysis(),
              Footer(),
            ],
          ),
        ),
      ),
    );
  }
}