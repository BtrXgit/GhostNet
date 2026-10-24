import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ciphercloak/apis/apis.dart';

class _RealNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealNetworkHttpOverrides();

  test('Verify APIs.getVPNServers country diversity', () async {
    final servers = await APIs.getVPNServers();
    expect(servers, isNotEmpty);

    final Map<String, int> countryCounts = {};
    for (var s in servers) {
      countryCounts[s.countryLong] = (countryCounts[s.countryLong] ?? 0) + 1;
    }

    print('\n=============================================');
    print('       SERVER DIVERSITY & COUNTRY REPORT     ');
    print('=============================================');
    print('Total Loaded Servers : ${servers.length}');
    print('Total Unique Countries: ${countryCounts.length}');
    print('---------------------------------------------');
    countryCounts.forEach((country, count) {
      print('  • $country: $count servers');
    });
    print('=============================================\n');

    expect(countryCounts.length, greaterThanOrEqualTo(10));
  });
}
