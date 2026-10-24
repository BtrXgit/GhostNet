import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

void main() {
  test('test ip fetch', () async {
    print('Testing ip-api.com...');
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 5));
      print('ip-api status: ${res.statusCode}');
      print('ip-api body: ${res.body}');
    } catch (e) {
      print('ip-api error: $e');
    }

    print('Testing ipwho.is...');
    try {
      final res = await get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 5));
      print('ipwho.is status: ${res.statusCode}');
      print('ipwho.is body: ${res.body}');
    } catch (e) {
      print('ipwho.is error: $e');
    }
  });
}
