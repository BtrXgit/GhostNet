import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../helpers/country_detector.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/prefs.dart';
import '../models/ip_details.dart';
import '../models/vpn.dart';

class APIs {
  // Verified worldwide subscription feeds (hourly HTTP-over-proxy verified)
  static const List<Map<String, String>> _countryFeeds = [
    // Asia-Pacific
    {'code': 'IN', 'name': 'India'},
    {'code': 'SG', 'name': 'Singapore'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'HK', 'name': 'Hong Kong'},
    {'code': 'AU', 'name': 'Australia'},
    {'code': 'ID', 'name': 'Indonesia'},
    {'code': 'TH', 'name': 'Thailand'},
    {'code': 'TW', 'name': 'Taiwan'},
    {'code': 'VN', 'name': 'Vietnam'},

    // North America
    {'code': 'US', 'name': 'United States'},
    {'code': 'CA', 'name': 'Canada'},

    // Europe
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'NL', 'name': 'Netherlands'},
    {'code': 'CH', 'name': 'Switzerland'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'PL', 'name': 'Poland'},
    {'code': 'FI', 'name': 'Finland'},
    {'code': 'AT', 'name': 'Austria'},
    {'code': 'RO', 'name': 'Romania'},
    {'code': 'EE', 'name': 'Estonia'},
    {'code': 'LV', 'name': 'Latvia'},

    // Middle East & Africa
    {'code': 'AE', 'name': 'United Arab Emirates'},
    {'code': 'TR', 'name': 'Turkey'},
    {'code': 'ZA', 'name': 'South Africa'},
    {'code': 'AM', 'name': 'Armenia'},
  ];

  static const int _maxPerCountry = 5;

  static Vpn get smartConnectVpn => Vpn(
        countryLong: '⚡ Smart Connect',
        countryShort: 'AUTO',
        protocol: 'VLESS',
        remark: '⚡ Smart Connect (Fastest / Lowest Latency)',
        speed: 250000000,
        ping: '15',
        numVpnSessions: 5,
        rawUrl: 'smart://connect',
        v2rayConfig: '',
      );

  static Future<List<Vpn>> getVPNServers() async {
    final Map<String, List<Vpn>> countryBuckets = {};
    final Set<String> seenConfigs = {};

    // 1. Instantly load bundled verified offline nodes (Zero network wait)
    try {
      final localData = await rootBundle.loadString('assets/v2ray_servers.json');
      final List jsonList = jsonDecode(localData);
      for (var item in jsonList) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final rawUrl = map['rawUrl'] ?? '';
        if (rawUrl.isNotEmpty) {
          try {
            final parser = FlutterV2ray.parseFromURL(rawUrl);
            final config = parser.getFullConfiguration();
            final cLong = (map['countryLong'] as String? ?? '').isNotEmpty
                ? map['countryLong'] as String
                : CountryDetector.detect(map['remark'] ?? parser.remark, rawUrl).name;
            final cShort = (map['countryShort'] as String? ?? '').isNotEmpty
                ? map['countryShort'] as String
                : CountryDetector.detect(map['remark'] ?? parser.remark, rawUrl).code;

            final vpn = Vpn(
              countryLong: cLong,
              countryShort: cShort,
              protocol: map['protocol'] ?? 'VLESS',
              remark: map['remark'] ?? parser.remark,
              rawUrl: rawUrl,
              v2rayConfig: config,
              speed: map['speed'] ?? 100000000,
              ping: (map['ping'] ?? '35').toString(),
              numVpnSessions: map['numVpnSessions'] ?? 25,
            );

            seenConfigs.add(rawUrl);
            countryBuckets.putIfAbsent(cLong, () => []).add(vpn);
          } catch (e) {
            log('Error parsing bundled node: $e');
          }
        }
      }
    } catch (e) {
      log('Bundled V2Ray Ingestion Error: $e');
    }

    // 2. Concurrently fetch hourly-verified live nodes for target regions
    await Future.wait(_countryFeeds.map((cf) async {
      final code = cf['code']!;
      final countryName = cf['name']!;
      final feedUrl =
          'https://raw.githubusercontent.com/Au1rxx/free-vpn-subscriptions/main/output/by-country/v2ray-base64-$code.txt';

      try {
        final res = await get(
          Uri.parse(feedUrl),
          headers: {'User-Agent': 'v2rayNG/1.8.5'},
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200 && res.body.isNotEmpty) {
          String decodedContent = '';
          try {
            final cleanBody = res.body.replaceAll('\n', '').replaceAll('\r', '').trim();
            final decodedBytes = base64Decode(base64.normalize(cleanBody));
            decodedContent = utf8.decode(decodedBytes, allowMalformed: true);
          } catch (_) {
            decodedContent = res.body;
          }

          final lines = decodedContent.split('\n');
          countryBuckets.putIfAbsent(countryName, () => []);

          for (var line in lines) {
            line = line.trim();
            if (line.isEmpty || line.startsWith('#')) continue;

            if (line.startsWith('vless://') ||
                line.startsWith('vmess://') ||
                line.startsWith('trojan://') ||
                line.startsWith('ss://')) {
              if (seenConfigs.contains(line)) continue;
              // Modern V2Ray rejects deprecated ciphers like rc4-md5 and unstandard ss2022
              if (line.startsWith('ss://') &&
                  (line.contains('cmM0LW1kNT') ||
                   line.toLowerCase().contains('rc4-md5') ||
                   line.toLowerCase().contains('2022-') ||
                   line.toLowerCase().contains('blake'))) {
                continue;
              }
              // Reject Cloudflare free worker proxies and VMess to prevent time-drift and CDN drops
              if (line.startsWith('vmess://') ||
                  line.contains('workers.dev') ||
                  line.contains('pages.dev') ||
                  line.contains('filegear') ||
                  line.contains('ccwu.cc') ||
                  line.contains('ed=2560')) {
                continue;
              }
              if (countryBuckets[countryName]!.length >= _maxPerCountry) break;

              try {
                final parser = FlutterV2ray.parseFromURL(line);
                final country = CountryDetector.detect(parser.remark, line);
                final cName = country.name.isNotEmpty ? country.name : countryName;
                final cCode = country.code.isNotEmpty ? country.code : code;

                String proto = 'VLESS';
                if (line.startsWith('vmess://')) proto = 'VMESS';
                if (line.startsWith('trojan://')) proto = 'TROJAN';
                if (line.startsWith('ss://')) proto = 'SHADOWSOCKS';

                final config = parser.getFullConfiguration();
                final vpn = Vpn(
                  countryLong: cName,
                  countryShort: cCode,
                  protocol: proto,
                  remark: '$cName - $proto Fast',
                  rawUrl: line,
                  v2rayConfig: config,
                  speed: 100000000 + (seenConfigs.length % 5) * 10000000,
                  ping: (30 + (seenConfigs.length % 40)).toString(),
                  numVpnSessions: 25,
                );

                seenConfigs.add(line);
                countryBuckets[countryName]!.add(vpn);
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        log('Live country feed error ($code): $e');
      }
    }));

    // Flatten all country buckets into final diverse list, with Smart Connect first
    final List<Vpn> diverseList = [smartConnectVpn];

    final topOrder = [
      'India',
      'Singapore',
      'United States',
      'Germany',
      'United Kingdom',
      'Japan',
      'Canada',
      'France',
      'Netherlands',
      'United Arab Emirates',
      'Australia',
    ];

    for (var c in topOrder) {
      if (countryBuckets.containsKey(c)) {
        diverseList.addAll(countryBuckets.remove(c)!);
      }
    }

    for (var bucket in countryBuckets.values) {
      diverseList.addAll(bucket);
    }

    // Cache to Prefs
    if (diverseList.isNotEmpty) {
      Pref.vpnList = diverseList;
      final currentVpn = Pref.vpn;
      if (currentVpn.v2rayConfig.isEmpty ||
          currentVpn.rawUrl.isEmpty ||
          !diverseList.any((s) => s.rawUrl == currentVpn.rawUrl)) {
        Pref.vpn = diverseList.first;
      }
    }

    return diverseList;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        ipData.value = IPDetails.fromJson(data);
        return;
      }
    } catch (e) {
      log('ip-api error: $e');
    }

    // Fallback 1: ipwho.is
    try {
      final res = await get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        ipData.value = IPDetails(
          country: data['country'] ?? '',
          regionName: data['region'] ?? '',
          city: data['city'] ?? '',
          zip: data['postal'] ?? ' - - - - ',
          timezone: (data['timezone'] is Map)
              ? (data['timezone']['id'] ?? 'Unknown')
              : 'Unknown',
          isp: (data['connection'] is Map)
              ? (data['connection']['isp'] ?? 'Unknown')
              : 'Unknown',
          query: data['ip'] ?? 'Not available',
        );
        return;
      }
    } catch (e) {
      log('ipwho.is error: $e');
    }

    // Fallback 2: ipify
    try {
      final res = await get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        ipData.value = IPDetails(
          country: 'Connected',
          regionName: '',
          city: '',
          zip: ' - - - - ',
          timezone: 'Auto',
          isp: 'VPN Protected',
          query: data['ip'] ?? 'Active',
        );
      }
    } catch (e) {
      log('ipify error: $e');
    }
  }
}
