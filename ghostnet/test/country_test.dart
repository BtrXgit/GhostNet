import 'package:flutter_test/flutter_test.dart';

class CountryInfo {
  final String name;
  final String code;

  const CountryInfo(this.name, this.code);
}

CountryInfo detectCountry(String rawRemark) {
  final decoded = Uri.decodeComponent(rawRemark);
  final lower = decoded.toLowerCase();

  // Flag Emoji or Code checks
  if (decoded.contains('🇺🇸') || lower.contains('united states') || lower.contains('usa') || lower.contains('america')) {
    return const CountryInfo('United States', 'US');
  }
  if (decoded.contains('🇩🇪') || lower.contains('germany') || lower.contains('deutschland') || lower.contains('frankfurt')) {
    return const CountryInfo('Germany', 'DE');
  }
  if (decoded.contains('🇬🇧') || lower.contains('united kingdom') || lower.contains('uk') || lower.contains('london') || lower.contains('england')) {
    return const CountryInfo('United Kingdom', 'GB');
  }
  if (decoded.contains('🇸🇬') || lower.contains('singapore')) {
    return const CountryInfo('Singapore', 'SG');
  }
  if (decoded.contains('🇯🇵') || lower.contains('japan') || lower.contains('tokyo')) {
    return const CountryInfo('Japan', 'JP');
  }
  if (decoded.contains('🇨🇦') || lower.contains('canada') || lower.contains('toronto')) {
    return const CountryInfo('Canada', 'CA');
  }
  if (decoded.contains('🇫🇷') || lower.contains('france') || lower.contains('paris')) {
    return const CountryInfo('France', 'FR');
  }
  if (decoded.contains('🇳🇱') || lower.contains('netherlands') || lower.contains('amsterdam')) {
    return const CountryInfo('Netherlands', 'NL');
  }
  if (decoded.contains('🇸🇪') || lower.contains('sweden')) {
    return const CountryInfo('Sweden', 'SE');
  }
  if (decoded.contains('🇧🇷') || lower.contains('brazil')) {
    return const CountryInfo('Brazil', 'BR');
  }
  if (decoded.contains('🇮🇳') || lower.contains('india') || lower.contains('mumbai')) {
    return const CountryInfo('India', 'IN');
  }
  if (decoded.contains('🇹🇷') || lower.contains('turkey')) {
    return const CountryInfo('Turkey', 'TR');
  }
  if (decoded.contains('🇰🇷') || lower.contains('korea')) {
    return const CountryInfo('South Korea', 'KR');
  }
  if (decoded.contains('🇦🇺') || lower.contains('australia') || lower.contains('sydney')) {
    return const CountryInfo('Australia', 'AU');
  }

  // Fallback defaults
  return const CountryInfo('United States', 'US');
}

void main() {
  test('Country detection test', () {
    expect(detectCountry('%F0%9F%87%BA%F0%9F%87%B8').code, 'US');
    expect(detectCountry('%F0%9F%87%A9%F0%9F%87%AA').code, 'DE');
    expect(detectCountry('%F0%9F%87%AB%F0%9F%87%B7').code, 'FR');
    expect(detectCountry('Frankfurt-Fast').code, 'DE');
    expect(detectCountry('United+States').code, 'US');
  });
}
