class CountryInfo {
  final String name;
  final String code;

  const CountryInfo(this.name, this.code);
}

class CountryDetector {
  static const Map<String, String> countryCodeToName = {
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
    'TH': 'Thailand',
    'ID': 'Indonesia',
    'VN': 'Vietnam',
    'IS': 'Iceland',
    'LU': 'Luxembourg',
    'HU': 'Hungary',
  };

  static CountryInfo detect(String rawRemark, [String rawUrl = '']) {
    String decoded;
    try {
      decoded = Uri.decodeComponent(rawRemark);
    } catch (_) {
      decoded = rawRemark;
    }

    // 1. Unicode Regional Indicator Flag Emoji Detection (Works for all 256 flags)
    final flagCode = _extractFlagCountryCode(decoded);
    if (flagCode != null && countryCodeToName.containsKey(flagCode)) {
      return CountryInfo(countryCodeToName[flagCode]!, flagCode);
    }

    final lowerRemark = decoded.toLowerCase();
    final lowerUrl = rawUrl.toLowerCase();
    final combined = '$lowerRemark $lowerUrl';

    // 2. Keyword & Domain heuristics
    if (combined.contains('singapore') || combined.contains('sg.') || combined.contains('.sg') || combined.contains('sg1') || combined.contains('sg2') || combined.contains('sg-')) {
      return const CountryInfo('Singapore', 'SG');
    }
    if (combined.contains('japan') || combined.contains('tokyo') || combined.contains('osaka') || combined.contains('jp.') || combined.contains('.jp') || combined.contains('jpz') || combined.contains('jp1') || combined.contains('jp-')) {
      return const CountryInfo('Japan', 'JP');
    }
    if (combined.contains('germany') || combined.contains('deutschland') || combined.contains('frankfurt') || combined.contains('berlin') || combined.contains('de.') || combined.contains('.de') || combined.contains('de4.') || combined.contains('de2.') || combined.contains('de9.') || combined.contains('de10.')) {
      return const CountryInfo('Germany', 'DE');
    }
    if (combined.contains('united kingdom') || combined.contains('london') || combined.contains('england') || combined.contains('uk.') || combined.contains('.uk') || combined.contains('uk1') || combined.contains('gb.')) {
      return const CountryInfo('United Kingdom', 'GB');
    }
    if (combined.contains('france') || combined.contains('paris') || combined.contains('fr.') || combined.contains('.fr')) {
      return const CountryInfo('France', 'FR');
    }
    if (combined.contains('canada') || combined.contains('toronto') || combined.contains('vancouver') || combined.contains('ca.') || combined.contains('.ca')) {
      return const CountryInfo('Canada', 'CA');
    }
    if (combined.contains('netherlands') || combined.contains('amsterdam') || combined.contains('nl.') || combined.contains('.nl')) {
      return const CountryInfo('Netherlands', 'NL');
    }
    if (combined.contains('sweden') || combined.contains('stockholm') || combined.contains('se.') || combined.contains('.se')) {
      return const CountryInfo('Sweden', 'SE');
    }
    if (combined.contains('switzerland') || combined.contains('zurich') || combined.contains('ch.') || combined.contains('.ch')) {
      return const CountryInfo('Switzerland', 'CH');
    }
    if (combined.contains('australia') || combined.contains('sydney') || combined.contains('melbourne') || combined.contains('au.') || combined.contains('.au')) {
      return const CountryInfo('Australia', 'AU');
    }
    if (combined.contains('india') ||
        combined.contains('mumbai') ||
        combined.contains('delhi') ||
        combined.contains('bangalore') ||
        combined.contains('bengaluru') ||
        combined.contains('hyderabad') ||
        combined.contains('chennai') ||
        combined.contains('kolkata') ||
        combined.contains('pune') ||
        combined.contains('airtel') ||
        combined.contains('jio') ||
        combined.contains('in-') ||
        combined.contains('-in.') ||
        RegExp(r'\b(in|ind)\b', caseSensitive: false).hasMatch(lowerRemark)) {
      return const CountryInfo('India', 'IN');
    }
    if (combined.contains('korea') || combined.contains('seoul') || combined.contains('kr.') || combined.contains('.kr')) {
      return const CountryInfo('South Korea', 'KR');
    }
    if (combined.contains('hong kong') || combined.contains('hk.') || combined.contains('.hk')) {
      return const CountryInfo('Hong Kong', 'HK');
    }
    if (combined.contains('brazil') || combined.contains('sao paulo') || combined.contains('br.') || combined.contains('.br')) {
      return const CountryInfo('Brazil', 'BR');
    }
    if (combined.contains('turkey') || combined.contains('istanbul') || combined.contains('tr.') || combined.contains('.tr')) {
      return const CountryInfo('Turkey', 'TR');
    }
    if (combined.contains('italy') || combined.contains('rome') || combined.contains('milan') || combined.contains('it.') || combined.contains('.it')) {
      return const CountryInfo('Italy', 'IT');
    }
    if (combined.contains('spain') || combined.contains('madrid') || combined.contains('es.') || combined.contains('.es')) {
      return const CountryInfo('Spain', 'ES');
    }
    if (combined.contains('finland') || combined.contains('helsinki') || combined.contains('fi.') || combined.contains('.fi')) {
      return const CountryInfo('Finland', 'FI');
    }
    if (combined.contains('norway') || combined.contains('oslo') || combined.contains('no.') || combined.contains('.no')) {
      return const CountryInfo('Norway', 'NO');
    }
    if (combined.contains('denmark') || combined.contains('copenhagen') || combined.contains('dk.') || combined.contains('.dk')) {
      return const CountryInfo('Denmark', 'DK');
    }
    if (combined.contains('poland') || combined.contains('warsaw') || combined.contains('pl.') || combined.contains('.pl')) {
      return const CountryInfo('Poland', 'PL');
    }
    if (combined.contains('estonia') || combined.contains('tallinn') || combined.contains('ee.') || combined.contains('.ee')) {
      return const CountryInfo('Estonia', 'EE');
    }
    if (combined.contains('lithuania') || combined.contains('vilnius') || combined.contains('lt.') || combined.contains('.lt')) {
      return const CountryInfo('Lithuania', 'LT');
    }
    if (combined.contains('latvia') || combined.contains('riga') || combined.contains('lv.') || combined.contains('.lv')) {
      return const CountryInfo('Latvia', 'LV');
    }
    if (combined.contains('austria') || combined.contains('vienna') || combined.contains('at.') || combined.contains('.at')) {
      return const CountryInfo('Austria', 'AT');
    }
    if (combined.contains('belgium') || combined.contains('brussels') || combined.contains('be.') || combined.contains('.be')) {
      return const CountryInfo('Belgium', 'BE');
    }
    if (combined.contains('ireland') || combined.contains('dublin') || combined.contains('ie.') || combined.contains('.ie')) {
      return const CountryInfo('Ireland', 'IE');
    }
    if (combined.contains('united states') || combined.contains('usa') || combined.contains('america') || combined.contains('us.') || combined.contains('us1') || combined.contains('us2') || combined.contains('new york') || combined.contains('california')) {
      return const CountryInfo('United States', 'US');
    }

    return const CountryInfo('United States', 'US');
  }

  static String? _extractFlagCountryCode(String input) {
    final runes = input.runes.toList();
    for (int i = 0; i < runes.length - 1; i++) {
      final r1 = runes[i];
      final r2 = runes[i + 1];
      if (r1 >= 0x1F1E6 && r1 <= 0x1F1FF && r2 >= 0x1F1E6 && r2 <= 0x1F1FF) {
        final char1 = String.fromCharCode(r1 - 0x1F1E6 + 65);
        final char2 = String.fromCharCode(r2 - 0x1F1E6 + 65);
        return '$char1$char2';
      }
    }
    return null;
  }
}
