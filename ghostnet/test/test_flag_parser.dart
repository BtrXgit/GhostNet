import 'package:flutter_test/flutter_test.dart';

const Map<String, String> countryCodeToName = {
  'US': 'United States',
  'GB': 'United Kingdom',
  'DE': 'Germany',
  'FR': 'France',
  'CA': 'Canada',
  'SG': 'Singapore',
  'JP': 'Japan',
  'NL': 'Netherlands',
  'SE': 'Sweden',
  'CH': 'Switzerland',
  'IT': 'Italy',
  'ES': 'Spain',
  'IN': 'India',
  'BR': 'Brazil',
  'TR': 'Turkey',
  'AU': 'Australia',
  'KR': 'South Korea',
  'HK': 'Hong Kong',
  'FI': 'Finland',
  'NO': 'Norway',
  'DK': 'Denmark',
  'PL': 'Poland',
  'LV': 'Latvia',
  'LT': 'Lithuania',
  'EE': 'Estonia',
  'AT': 'Austria',
  'BE': 'Belgium',
  'IE': 'Ireland',
  'PT': 'Portugal',
  'MY': 'Malaysia',
  'AE': 'United Arab Emirates',
  'SA': 'Saudi Arabia',
  'ZA': 'South Africa',
  'RO': 'Romania',
  'CZ': 'Czech Republic',
  'GR': 'Greece',
  'NZ': 'New Zealand',
  'UA': 'Ukraine',
  'IR': 'Iran',
  'RU': 'Russia',
};

String? extractFlagCountryCode(String input) {
  final runes = input.runes.toList();
  for (int i = 0; i < runes.length - 1; i++) {
    final r1 = runes[i];
    final r2 = runes[i + 1];
    // Check if both runes are Regional Indicator Symbols (0x1F1E6 to 0x1F1FF)
    if (r1 >= 0x1F1E6 && r1 <= 0x1F1FF && r2 >= 0x1F1E6 && r2 <= 0x1F1FF) {
      final char1 = String.fromCharCode(r1 - 0x1F1E6 + 65);
      final char2 = String.fromCharCode(r2 - 0x1F1E6 + 65);
      return '$char1$char2';
    }
  }
  return null;
}

void main() {
  test('Dynamic flag emoji parser', () {
    expect(extractFlagCountryCode('Channel id: @ShadowProxy66 🇸🇪'), 'SE');
    expect(extractFlagCountryCode('🇩🇪All¹ | @BigSmoke_Config'), 'DE');
    expect(extractFlagCountryCode('United States 🇺🇸'), 'US');
    expect(extractFlagCountryCode('Japan 🇯🇵 Fast'), 'JP');
    expect(extractFlagCountryCode('Singapore 🇸🇬 Node'), 'SG');
    expect(extractFlagCountryCode('Channel 🇱🇹 test'), 'LT');
    expect(extractFlagCountryCode('Estonia 🇪🇪 node'), 'EE');
    expect(extractFlagCountryCode('Brazil 🇧🇷 fast'), 'BR');
    expect(extractFlagCountryCode('Australia 🇦🇺'), 'AU');

    // Test with URL-encoded emoji
    final decoded = Uri.decodeComponent('%F0%9F%87%B8%F0%9F%87%AC');
    expect(extractFlagCountryCode(decoded), 'SG');
  });
}
