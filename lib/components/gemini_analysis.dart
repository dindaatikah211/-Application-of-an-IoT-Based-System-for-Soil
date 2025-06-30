import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mqtt_service.dart';
import '../services/gemini_service.dart';

class GeminiAnalysis extends StatefulWidget {
  const GeminiAnalysis({super.key});

  @override
  State<GeminiAnalysis> createState() => _GeminiAnalysisState();
}

class _GeminiAnalysisState extends State<GeminiAnalysis> {
  final GeminiService _geminiService = GeminiService();
  String geminiResponse = "Memuat analisis AI...";
  List<String> recommendations = [];
  String healthStatus = "Memuat...";
  String weatherPrediction = "Memuat...";
  bool isLoading = false;
  int retryCount = 0;
  final int maxRetries = 2;

  @override
  void initState() {
    super.initState();
    // Auto-load saat widget pertama kali dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGeminiAnalysis();
    });
  }

  Future<void> _loadGeminiAnalysis() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
      geminiResponse = "Memuat analisis AI...";
      recommendations = [];
      healthStatus = "Memuat...";
      weatherPrediction = "Memuat...";
    });

    try {
      final mqttService = Provider.of<MqttService>(context, listen: false);

      // Timeout yang lebih pendek untuk Gemini API
      final result = await _geminiService.analyzeSensorData(
        soilTemperature: mqttService.suhu,
        soilMoisture: mqttService.kelembapan.toDouble(),
        airTemperature: mqttService.suhuUdara,
        lightIntensity: mqttService.cahaya,
        isRaining: mqttService.statusHujan,
        soilMatrixPressure: 15.0,
      ).timeout(Duration(seconds: 10));

      setState(() {
        geminiResponse = result['analysis'] ?? 'Analisis tidak tersedia';
        recommendations = List<String>.from(result['recommendations'] ?? []);
        healthStatus = result['health_status'] ?? 'Unknown';
        weatherPrediction = result['weather_prediction'] ?? 'Prediksi tidak tersedia';
        isLoading = false;
      });
      retryCount = 0; // Reset retry count on success

    } catch (e) {
      // Jika timeout atau connection error, coba retry
      if ((e.toString().contains('TimeoutException') || 
           e.toString().contains('SocketException') ||
           e.toString().contains('ClientException')) && 
          retryCount < maxRetries) {
        retryCount++;
        setState(() {
          geminiResponse = "Koneksi bermasalah, mencoba lagi... ($retryCount/$maxRetries)";
          isLoading = false;
        });
        
        await Future.delayed(Duration(seconds: 2));
        _loadGeminiAnalysis();
        return;
      }

      // Jika sudah maksimal retry atau error lain, gunakan analisis lokal
      _setLocalAnalysis(error: e.toString());
    }
  }

  void _setLocalAnalysis({String? error}) {
    final mqttService = Provider.of<MqttService>(context, listen: false);
    
    // Analisis berdasarkan data sensor secara lokal
    final temp = mqttService.suhu;
    final moisture = mqttService.kelembapan;
    final airTemp = mqttService.suhuUdara;
    final light = mqttService.cahaya;
    final isRaining = mqttService.statusHujan;

    String analysis;
    String status;
    List<String> recs;

    if (temp == 0.0 && moisture == 0) {
      analysis = "⚠ Mode Offline - Tidak dapat terhubung ke AI dan sensor tidak aktif. "
          "Periksa koneksi internet dan pastikan perangkat IoT menyala.";
      status = 'Offline';
      recs = [
        'Periksa koneksi WiFi/internet',
        'Restart aplikasi dan router',
        'Pastikan perangkat IoT online',
        'Coba lagi dalam beberapa menit'
      ];
    } else {
      // Analisis sederhana berdasarkan data yang ada
      List<String> conditions = [];
      
      if (temp > 35) {
        conditions.add('suhu tanah tinggi (${temp.toStringAsFixed(1)}°C)');
      } else if (temp < 15) {
        conditions.add('suhu tanah rendah (${temp.toStringAsFixed(1)}°C)');
      } else {
        conditions.add('suhu tanah normal (${temp.toStringAsFixed(1)}°C)');
      }
      
      if (moisture < 30) {
        conditions.add('tanah kering ($moisture%)');
      } else if (moisture > 80) {
        conditions.add('tanah basah ($moisture%)');
      } else {
        conditions.add('kelembapan optimal ($moisture%)');
      }
      
      if (light < 200) {
        conditions.add('cahaya kurang (${light.toStringAsFixed(0)} lux)');
      } else if (light > 1500) {
        conditions.add('cahaya berlebih (${light.toStringAsFixed(0)} lux)');
      } else {
        conditions.add('cahaya cukup (${light.toStringAsFixed(0)} lux)');
      }
      
      analysis = "🤖 Analisis Lokal - ${conditions.join(', ')}. "
          "${isRaining ? 'Cuaca: sedang hujan. ' : 'Cuaca: tidak hujan. '}"
          "Suhu udara ${airTemp.toStringAsFixed(1)}°C. "
          "AI offline, analisis berdasarkan algoritma lokal.";
      
      // Tentukan status kesehatan
      if (temp > 35 || moisture < 30 || temp < 15) {
        status = 'Perhatian';
      } else if (temp >= 25 && temp <= 30 && moisture >= 40 && moisture <= 70) {
        status = 'Optimal';
      } else {
        status = 'Baik';
      }

      recs = [];
      if (moisture < 30) {
        recs.add('🚰 Perbanyak penyiraman - tanah terlalu kering');
      }
      if (moisture > 80) {
        recs.add('🛑 Kurangi penyiraman - tanah terlalu basah');
      }
      if (temp > 35) {
        recs.add('🌂 Berikan naungan - suhu terlalu tinggi');
      }
      if (temp < 15) {
        recs.add('☀ Hangatkan area tanam - suhu terlalu dingin');
      }
      if (light < 200) {
        recs.add('💡 Tingkatkan pencahayaan');
      }
      if (light > 1500) {
        recs.add('🌫 Kurangi intensitas cahaya langsung');
      }
      if (isRaining && moisture > 70) {
        recs.add('⛱ Lindungi dari hujan berlebih');
      }
      
      if (recs.isEmpty) {
        recs.add('✅ Kondisi tanaman dalam keadaan baik');
      }
      
      recs.add('🔄 Tekan "Refresh" untuk mencoba koneksi AI lagi');
    }

    setState(() {
      geminiResponse = analysis;
      recommendations = recs;
      healthStatus = status;
      weatherPrediction = isRaining 
          ? '🌧 Cuaca: Hujan (deteksi lokal)' 
          : '☀ Cuaca: Cerah (deteksi lokal)';
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5), // Lighter background color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF4CAF50).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFF9C27B0), // Darker color for the icon background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.psychology, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Feedback AI',
                  style: TextStyle(
                    color: Color(0xFF404040), // Darker text color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: isLoading ? null : () {
                  retryCount = 0; // Reset retry count
                  _loadGeminiAnalysis();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            geminiResponse,
            style: TextStyle(
              color: Color(0xFF404040), // Darker text color
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (recommendations.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              'Rekomendasi:',
              style: TextStyle(
                color: Color(0xFF404040), // Darker text color
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...recommendations.map(
              (rec) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(0xFF9C27B0), // Darker color for the bullet
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          color: Color(0xFF404040), // Darker text color
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (weatherPrediction.isNotEmpty && weatherPrediction != 'Memuat...') ...[
            SizedBox(height: 16),
            Text(
              'Prediksi Cuaca:',
              style: TextStyle(
                color: Color(0xFF404040), // Darker text color
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              weatherPrediction,
              style: TextStyle(
                color: Color(0xFF404040), // Darker text color
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}