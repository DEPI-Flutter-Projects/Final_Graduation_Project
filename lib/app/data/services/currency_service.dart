import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String _apiKey = '39a2942b793d80d160c9b121641dd96cd0385cd0';
  static const String _baseUrl = 'https://api.getgeoapi.com/v2/currency';

  
  final Map<String, double> _cache = {};

  Future<double?> getExchangeRate(String from, String to) async {
    if (from == to) return 1.0;

    final cacheKey = '${from}_$to';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/convert?api_key=$_apiKey&from=$from&to=$to&amount=1&format=json');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final rates = data['rates'];
          if (rates != null && rates[to] != null) {
            final rate = double.tryParse(rates[to]['rate'].toString());
            if (rate != null) {
              _cache[cacheKey] = rate;
              return rate;
            }
          }
        } else {
          debugPrint('Currency API Error: ${data['error']}');
        }
      } else {
        debugPrint('Currency API HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Currency Service Exception: $e');
    }
    return null;
  }
}
