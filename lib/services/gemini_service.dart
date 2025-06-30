import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyBNfnWSXMHdtIagpeN-xPK_6H-YNX5W89Y';
  late final GenerativeModel _model;

  GeminiService() {
    print('🔧 [DEBUG] Initializing GeminiService...');
    try {
      _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      print('✅ [DEBUG] GeminiService initialized successfully');
    } catch (e) {
      print('❌ [DEBUG] Error initializing GeminiService: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeSensorData({
    required double soilTemperature,
    required double soilMoisture,
    required double airTemperature,
    required double lightIntensity,
    required bool isRaining,
    required double soilMatrixPressure,
  }) async {
    print('\n🚀 [DEBUG] Starting Gemini analysis...');
    print('📊 [DEBUG] Input data:');
    print('   - Suhu Tanah: ${soilTemperature.toStringAsFixed(1)}°C');
    print('   - Kelembapan Tanah: ${soilMoisture.toStringAsFixed(0)}%');
    print('   - Suhu Udara: ${airTemperature.toStringAsFixed(0)}°C');
    print('   - Intensitas Cahaya: ${lightIntensity.toStringAsFixed(0)} lux');
    print('   - Status Hujan: ${isRaining ? 'Sedang hujan' : 'Tidak hujan'}');
    print('   - Tekanan Tanah: ${soilMatrixPressure.toStringAsFixed(1)} kPa');

    final prompt =
        '''
Saya memiliki data sensor tanaman IoT berikut:
- Suhu Tanah: ${soilTemperature.toStringAsFixed(1)}°C
- Kelembapan Tanah: ${soilMoisture.toStringAsFixed(0)}%
- Suhu Udara: ${airTemperature.toStringAsFixed(0)}°C
- Intensitas Cahaya: ${lightIntensity.toStringAsFixed(0)} lux
- Status Hujan: ${isRaining ? 'Sedang hujan' : 'Tidak hujan'}
- Tekanan Tanah: ${soilMatrixPressure.toStringAsFixed(1)} kPa

Tolong analisis secara KRITIS. Jika ada parameter ekstrem, panas, tekanan tinggi, atau kelembapan rendah, jangan menyebut 'baik'. Jelaskan kondisi sebenarnya.

Berikan respons dalam format JSON sebagai berikut:
{
  "analysis": "kalimat ringkas analisis kondisi tanaman",
  "health_status": "Optimal/Baik/Perhatian/Bahaya",
  "recommendations": ["rekomendasi1", "rekomendasi2", "rekomendasi3", "rekomendasi4"],
  "weather_prediction": "kalimat prediksi cuaca atau lingkungan"
}

Gunakan bahasa Indonesia yang jelas dan langsung.
''';

    print('📝 [DEBUG] Prompt prepared, length: ${prompt.length} characters');
    print('📝 [DEBUG] Prompt content:\n$prompt\n');

    try {
      print('🌐 [DEBUG] Sending request to Gemini API...');
      final stopwatch = Stopwatch()..start();

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      stopwatch.stop();
      print(
        '⏱ [DEBUG] API call completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ [DEBUG] Response received from Gemini');
        print(
          '📄 [DEBUG] Raw response length: ${response.text!.length} characters',
        );
        print('📄 [DEBUG] Raw response:\n${response.text!}\n');

        final responseText = response.text!;

        // Coba ekstrak JSON
        print('🔍 [DEBUG] Attempting to extract JSON...');
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);

        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          print('✅ [DEBUG] JSON found: $jsonString');

          try {
            final Map<String, dynamic> json = jsonDecode(jsonString);
            print('✅ [DEBUG] JSON parsed successfully');
            print('📊 [DEBUG] Parsed data: $json');

            final result = {
              'analysis': json['analysis'] ?? 'Analisis tidak tersedia',
              'health_status': json['health_status'] ?? 'Unknown',
              'recommendations': List<String>.from(
                json['recommendations'] ?? ['Tidak ada rekomendasi'],
              ),
              'weather_prediction':
                  json['weather_prediction'] ?? 'Prediksi tidak tersedia',
            };

            print('🎉 [DEBUG] Final result prepared: $result');
            return result;
          } catch (parseError) {
            print('❌ [DEBUG] JSON parse error: $parseError');
            return {
              'analysis': 'Error parsing JSON: $parseError\nRaw: $jsonString',
              'health_status': 'Error',
              'recommendations': ['Gagal parsing respons AI'],
              'weather_prediction': 'Error parsing',
            };
          }
        } else {
          print('❌ [DEBUG] No JSON found in response');
          return {
            'analysis':
                'Gemini tidak mengembalikan format JSON yang valid.\nOutput: $responseText',
            'health_status': 'Error',
            'recommendations': ['Format respons tidak sesuai'],
            'weather_prediction': 'Error format',
          };
        }
      } else {
        print('❌ [DEBUG] Empty or null response from Gemini');
        print('🔍 [DEBUG] Response object: $response');
        return {
          'analysis': 'Gemini mengembalikan respons kosong',
          'health_status': 'Error',
          'recommendations': ['Tidak ada respons dari AI'],
          'weather_prediction': 'Error respons kosong',
        };
      }
    } catch (e, stackTrace) {
      print('❌ [DEBUG] Exception in analyzeSensorData: $e');
      print('📋 [DEBUG] Stack trace: $stackTrace');

      return {
        'analysis': 'Error komunikasi dengan Gemini: $e',
        'health_status': 'Error',
        'recommendations': ['Periksa koneksi internet dan API key'],
        'weather_prediction': 'Error koneksi',
      };
    }
  }
}