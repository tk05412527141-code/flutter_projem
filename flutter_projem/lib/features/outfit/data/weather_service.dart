import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();

  // Ücretsiz bir hava durumu API'si örneği (Open-Meteo API key gerektirmez)
  Future<double> getCurrentTemperature(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current_weather': true,
        },
      );

      if (response.statusCode == 200) {
        // API'den gelen sıcaklık verisini oku
        final temp = response.data['current_weather']['temperature'];
        return (temp as num).toDouble();
      }
      return 20.0; // Hata durumunda güvenli varsayılan değer
    } catch (e) {
      print('Hava durumu çekilemedi: $e');
      return 20.0; 
    }
  }
}