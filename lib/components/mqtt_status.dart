import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';

class MqttStatus extends StatelessWidget {
  const MqttStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MqttService>(context);

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mqttService.isConnected
            ? Color(0xFF4CAF50).withOpacity(0.1) // Light green background
            : Color(0xFFF44336).withOpacity(0.1), // Light red background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mqttService.isConnected
              ? Color(0xFF4CAF50).withOpacity(0.3) // Light green border
              : Color(0xFFF44336).withOpacity(0.3), // Light red border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            mqttService.isConnected ? Icons.wifi : Icons.wifi_off,
            color: mqttService.isConnected
                ? Color(0xFF4CAF50) // Green icon
                : Color(0xFFF44336), // Red icon
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status MQTT',
                  style: TextStyle(color: Colors.black54, fontSize: 12), // Darker text color
                ),
                Text(
                  mqttService.isConnected
                      ? 'Terhubung • Koneksi aktif'
                      : 'Terputus • Tidak ada koneksi',
                  style: TextStyle(
                    color: Colors.black, // Darker text color
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (mqttService.lastError.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      mqttService.lastError,
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: mqttService.isConnected
                  ? Color(0xFF4CAF50) // Green dot
                  : Color(0xFFF44336), // Red dot
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}