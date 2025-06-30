import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mqtt_service.dart';

class MqttConfigSection extends StatefulWidget {
  const MqttConfigSection({super.key});

  @override
  _MqttConfigSectionState createState() => _MqttConfigSectionState();
}

class _MqttConfigSectionState extends State<MqttConfigSection> {
  final TextEditingController _ipController = TextEditingController(
    text: '172.20.10.2',
  );
  final TextEditingController _userController = TextEditingController(
    text: 'ubuntu',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password',
  );
  bool _showMqttConfig = false;

  @override
  Widget build(BuildContext context) {
    final mqttService = Provider.of<MqttService>(context);

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF), // Lighter background color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFB0B0B0), width: 1), // Lighter border color
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showMqttConfig = !_showMqttConfig;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.black54, size: 24), // Darker icon color
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Konfigurasi MQTT',
                      style: TextStyle(
                        color: Colors.black, // Darker text color
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _showMqttConfig
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black54, // Darker icon color
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_showMqttConfig) ...[
            Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(color: Color(0xFFB0B0B0), height: 1), // Lighter divider color
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _ipController,
                    label: 'IP Address MQTT Broker',
                    hint: 'Masukkan IP Address (contoh: 172.20.10.2)',
                    icon: Icons.computer,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: _userController,
                    label: 'Username',
                    hint: 'Masukkan username MQTT',
                    icon: Icons.person,
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Masukkan password MQTT',
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: mqttService.isConnected
                              ? null
                              : _connectMqtt,
                          icon: Icon(Icons.wifi, size: 18),
                          label: Text('Connect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50), // Green button
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: mqttService.isConnected
                              ? _disconnectMqtt
                              : null,
                          icon: Icon(Icons.wifi_off, size: 18),
                          label: Text('Disconnect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFF44336), // Red button
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (mqttService.lastError.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        mqttService.lastError,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _connectMqtt() async {
    try {
      final mqttService = Provider.of<MqttService>(context, listen: false);
      await mqttService.connect(
        server: _ipController.text,
        port: 1883, // Port default MQTT
        username: _userController.text,
        password: _passwordController.text,
      );

      // Refresh UI
      setState(() {});
    } catch (e) {
      print('Connection error: $e');
    }
  }

  void _disconnectMqtt() {
    final mqttService = Provider.of<MqttService>(context, listen: false);
    mqttService.disconnect();
    setState(() {});
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black54, // Darker label color
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: Colors.black, fontSize: 14), // Darker text color
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black38, fontSize: 13), // Lighter hint color
            prefixIcon: Icon(icon, color: Colors.black54, size: 20), // Darker icon color
            filled: true,
            fillColor: Color(0xFFEFEFEF), // Lighter fill color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFE8B86D), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}