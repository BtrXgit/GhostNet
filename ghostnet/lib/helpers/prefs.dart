import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vpn.dart';

class Pref {
  static Box? _box;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('data');
  }

  static bool _hasBox() => _box != null && _box!.isOpen;

  //for storing theme data
  static bool get isDarkMode => _hasBox() ? (_box!.get('isDarkMode') ?? false) : false;
  static set isDarkMode(bool v) {
    if (_hasBox()) _box!.put('isDarkMode', v);
  }

  //for storing single selected vpn details
  static Vpn get vpn {
    if (!_hasBox()) {
      return Vpn(
        countryLong: 'Select Location',
        countryShort: 'us',
        rawUrl: '',
        v2rayConfig: '',
        protocol: 'VLESS',
        remark: 'Select a Server',
      );
    }
    final raw = _box!.get('vpn');
    if (raw == null || raw == '{}') {
      return Vpn(
        countryLong: 'Select Location',
        countryShort: 'us',
        rawUrl: '',
        v2rayConfig: '',
        protocol: 'VLESS',
        remark: 'Select a Server',
      );
    }
    try {
      return Vpn.fromJson(jsonDecode(raw));
    } catch (_) {
      return Vpn(
        countryLong: 'Select Location',
        countryShort: 'us',
        rawUrl: '',
        v2rayConfig: '',
        protocol: 'VLESS',
        remark: 'Select a Server',
      );
    }
  }

  static set vpn(Vpn v) {
    if (_hasBox()) _box!.put('vpn', jsonEncode(v));
  }

  //for storing vpn servers details
  static List<Vpn> get vpnList {
    if (!_hasBox()) return [];
    List<Vpn> temp = [];
    try {
      final data = jsonDecode(_box!.get('vpnList') ?? '[]');
      for (var i in data) temp.add(Vpn.fromJson(i));
    } catch (_) {}
    return temp;
  }

  static set vpnList(List<Vpn> v) {
    if (_hasBox()) _box!.put('vpnList', jsonEncode(v));
  }
}
