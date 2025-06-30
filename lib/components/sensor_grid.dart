import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';
import 'package:fl_chart/fl_chart.dart';

class SensorGrid extends StatelessWidget {
  const SensorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MqttService>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Kelembapan Tanah',
                  '${mqttService.kelembapan}%',
                  Icons.water_drop,
                  Color(0xFF2196F3), // Blue
                  _getStatus('moisture', mqttService.kelembapan.toDouble()),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  'Suhu Tanah',
                  '${mqttService.suhu.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Color(0xFFF44336), // Red
                  _getStatus('temperature', mqttService.suhu.toDouble()),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Suhu Udara',
                  '${mqttService.suhuUdara.toStringAsFixed(1)}°C',
                  Icons.wb_sunny,
                  Color(0xFFFF9800), // Orange
                  _getStatus('temperature', mqttService.suhuUdara),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  'Intensitas Cahaya',
                  '${mqttService.cahaya.toStringAsFixed(0)} lux',
                  Icons.light_mode,
                  Color.fromARGB(255, 218, 197, 10), // Yellow
                  _getStatus('light', mqttService.cahaya),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Kelembapan Udara',
                  '${mqttService.kelembapanUdara.toStringAsFixed(1)}%',
                  Icons.water_drop_outlined,
                  Color(0xFF00BCD4), // Cyan
                  _getStatus('moisture', mqttService.kelembapanUdara),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildRainDetectionSmall(mqttService),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Grafik Suhu Tanah',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Darker color for the title
            ),
          ),
          SizedBox(height: 8),
          _buildTemperatureGraph(mqttService),
        ],
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color, String status) {
    return Card(
      color: Color(0xFFEFEFEF), // Lighter background color for the card
      elevation: 4, // Add some elevation for a shadow effect
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.black87, fontSize: 14), // Darker text color
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.black, // Darker value color
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatus(String type, double value) {
    if (type == 'temperature') {
      if (value < 20) return 'Dingin';
      if (value > 35) return 'Panas';
      return 'Normal';
    } else if (type == 'moisture') {
      if (value < 30) return 'Kering';
      if (value > 80) return 'Basah';
      return 'Normal';
    } else if (type == 'light') {
      if (value < 1000) return 'Redup';
      if (value > 10000) return 'Terang';
      return 'Normal';
    }
    return 'Normal';
  }

  Widget _buildRainDetectionSmall(MqttService mqttService) {
    return Card(
      color: Color(0xFFEFEFEF), // Lighter background color for the card
      elevation: 4, // Add some elevation for a shadow effect
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(Icons.cloud, color: Colors.lightBlueAccent, size: 32),
            SizedBox(height: 8),
            Text(
              'Status Hujan',
              style: TextStyle(color: Colors.black87, fontSize: 14), // Darker text color
            ),
            SizedBox(height: 4),
            Text(
              mqttService.statusHujan ? 'HUJAN' : 'TIDAK HUJAN',
              style: TextStyle(
                color: mqttService.statusHujan ? Colors.blue : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Analog: ${mqttService.hujanAnalog}',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureGraph(MqttService mqttService) {
    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          minX: 0,
          maxX: 10,
          minY: 0,
          maxY: 50,
          lineBarsData: [
            LineChartBarData(
              spots: _getTemperatureData(mqttService),
              isCurved: true,
              color: Color(0xFFF44336), // Red color for the line
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getTemperatureData(MqttService mqttService) {
    // Example data points for the graph
    return [
      FlSpot(0, mqttService.suhu.toDouble()),
      FlSpot(1, mqttService.suhu.toDouble() - 5),
      FlSpot(2, mqttService.suhu.toDouble() + 3),
      FlSpot(3, mqttService.suhu.toDouble() - 2),
      FlSpot(4, mqttService.suhu.toDouble() + 4),
      FlSpot(5, mqttService.suhu.toDouble() - 1),
      FlSpot(6, mqttService.suhu.toDouble() + 6),
      FlSpot(7, mqttService.suhu.toDouble() - 3),
      FlSpot(8, mqttService.suhu.toDouble() + 2),
      FlSpot(9, mqttService.suhu.toDouble() - 4),
      FlSpot(10, mqttService.suhu.toDouble()),
    ];
  }
}