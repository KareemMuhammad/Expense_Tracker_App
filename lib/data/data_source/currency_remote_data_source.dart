import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyRemoteDataSource{
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  Future<Map<String, num>> getExchangeRates(String baseCurrency) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, num>.from(data['rates']);
        return rates;
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Error fetching exchange rates: $e');
    }
  }

  Future<double> convertCurrency(
      double amount,
      String fromCurrency,
      String toCurrency,
      ) async {
    if (fromCurrency == toCurrency) return amount;

    try {
      final rates = await getExchangeRates(fromCurrency);
      final rate = rates[toCurrency];

      if (rate == null) {
        throw Exception('Currency $toCurrency not found');
      }

      return amount * rate;
    } catch (e) {
      throw Exception('Error converting currency: $e');
    }
  }

  List<String> getSupportedCurrencies() {
    return [
      'USD', 'EUR', 'GBP', 'EGP', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD',
      'MXN', 'SGD', 'HKD', 'NOK', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR', 'KRW'
    ];
  }
}