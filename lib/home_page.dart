import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> dummyData = {
    'moisture': [0.32, 0.29, 0.27],
    'matricPotential': [-12.4, -10.1],
    'temperature': 24.5,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F2),
      appBar: AppBar(
        title: const Text(
          'SHYPROM Monitoring',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B4226),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Soil Data Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade700,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 24),
            SensorCard(
              icon: Icons.water_drop_outlined,
              iconColor: Colors.teal,
              title: 'Soil Moisture (θ)',
              unit: 'cm³/cm³',
              values: dummyData['moisture'],
              depths: ['z1', 'z2', 'z3'],
            ),
            const SizedBox(height: 20),
            SensorCard(
              icon: Icons.speed,
              iconColor: Colors.deepOrange,
              title: 'Matric Potential (h)',
              unit: 'kPa',
              values: dummyData['matricPotential'],
              depths: ['z_min', 'z_max'],
            ),
            const SizedBox(height: 20),
            _buildTemperatureCard(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing data...')),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    List<FlSpot> moistureSpots = [
      FlSpot(1, dummyData['moisture'][0]),
      FlSpot(2, dummyData['moisture'][1]),
      FlSpot(3, dummyData['moisture'][2]),
    ];

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.green.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Soil Moisture Chart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('z${value.toInt()}');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: moistureSpots,
                      isCurved: true,
                      color: Colors.green.shade700,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.thermostat, color: Colors.orange),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Temperature',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Text(
              '${dummyData['temperature']} °C',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final String title;
  final String unit;
  final List<double> values;
  final List<String> depths;
  final IconData icon;
  final Color iconColor;

  const SensorCard({
    required this.title,
    required this.unit,
    required this.values,
    required this.depths,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(thickness: 1),
            const SizedBox(height: 10),
            Column(
              children: List.generate(values.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Depth ${depths[index]}',
                          style: const TextStyle(fontSize: 15)),
                      Text('${values[index].toStringAsFixed(3)} $unit',
                          style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
