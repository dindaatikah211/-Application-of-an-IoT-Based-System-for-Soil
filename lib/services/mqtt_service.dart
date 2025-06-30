import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService extends ChangeNotifier {
  late MqttServerClient client;
  bool isConnected = false;
  String lastError = '';
  String lastSuccess = '';

  // Data sensor dari berbagai node
  int kelembapan = 0;
  double cahaya = 0.0;
  int hujanAnalog = 0;
  bool statusHujan = false;
  double suhu = 0.0;
  double suhuUdara = 0.0;
  double kelembapanUdara = 0.0;
  double soilMatrixPressure = 0.0; // Tambahkan ini

  Future<void> connect({
    required String server,
    required int port,
    required String username,
    required String password,
  }) async {
    try {
      client = MqttServerClient(
        server,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      );
      client.port = port;
      client.keepAlivePeriod = 30;
      client.secure = false;
      client.logging(on: true);
      client.connectTimeoutPeriod = 5;

      client.onConnected = _onConnected;
      client.onDisconnected = _onDisconnected;
      client.pongCallback = _onPong;

      final connMess = MqttConnectMessage()
          .withClientIdentifier('flutter_client')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      if (username.isNotEmpty && password.isNotEmpty) {
        connMess.authenticateAs(username, password);
      }

      client.connectionMessage = connMess;

      print('Connecting to $server:$port...');
      await client.connect();

      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        isConnected = false;
        lastError = 'Failed to connect: ${client.connectionStatus}';
        notifyListeners();
        throw Exception(lastError);
      }
    } catch (e) {
      isConnected = false;
      lastError = 'Connection error: $e';
      notifyListeners();
      print('MQTT Error: $e');
      throw Exception('MQTT Connection Error: $e');
    }
  }

  void _onConnected() {
    isConnected = true;
    lastSuccess = 'MQTT Connected successfully';
    lastError = '';
    notifyListeners();
    print('MQTT Connected');

    // Subscribe ke semua topic setelah terkoneksi
    _subscribeToAllTopics();

    // Listen untuk pesan masuk
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      _handleIncomingMessage(c[0].topic, message);
    });
  }

  void _subscribeToAllTopics() {
    // Subscribe ke semua topic dari berbagai node
    client.subscribe('node1/kelembapan', MqttQos.atMostOnce);
    client.subscribe('node1/cahaya', MqttQos.atMostOnce);
    client.subscribe('node2/hujan_analog', MqttQos.atMostOnce);
    client.subscribe('node2/hujan', MqttQos.atMostOnce);
    client.subscribe('node2/suhu', MqttQos.atMostOnce);
    client.subscribe('node3/suhu', MqttQos.atMostOnce);
    client.subscribe('node3/kelembapan', MqttQos.atMostOnce);
    client.subscribe('node1/soil_matrix_pressure', MqttQos.atMostOnce); // Tambahkan ini

    // Topic lama untuk backward compatibility
    client.subscribe('sensor/kelembapan', MqttQos.atMostOnce);

    print('Subscribed to all sensor topics');
  }

  void _handleIncomingMessage(String topic, String message) {
    print('Received: $topic -> $message');

    // Update data sesuai topic
    if (topic == 'node1/kelembapan' || topic == 'sensor/kelembapan') {
      kelembapan = int.tryParse(message) ?? 0;
    } else if (topic == 'node1/cahaya') {
      cahaya = double.tryParse(message) ?? 0.0;
    } else if (topic == 'node2/hujan_analog') {
      hujanAnalog = int.tryParse(message) ?? 0;
    } else if (topic == 'node2/hujan') {
      statusHujan = message == '1';
    } else if (topic == 'node2/suhu') {
      suhu = double.tryParse(message) ?? 0.0;
    } else if (topic == 'node3/suhu') {
      suhuUdara = double.tryParse(message) ?? 0.0;
    } else if (topic == 'node3/kelembapan') {
      kelembapanUdara = double.tryParse(message) ?? 0.0;
    } else if (topic == 'node1/soil_matrix_pressure') {
      soilMatrixPressure = double.tryParse(message) ?? 0.0;
      notifyListeners();
    }

    // Notify listeners untuk update UI
    notifyListeners();
  }

  void _onDisconnected() {
    isConnected = false;
    lastError = 'MQTT Disconnected';
    notifyListeners();
    print('MQTT Disconnected');
  }

  void _onPong() {
    print('Ping response received');
  }

  Future<void> subscribe(String topic) async {
    if (isConnected) {
      print('Subscribing to $topic');
      client.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void disconnect() {
    if (isConnected) {
      client.disconnect();
      isConnected = false;
      notifyListeners();
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get updates {
    return client.updates;
  }
}
