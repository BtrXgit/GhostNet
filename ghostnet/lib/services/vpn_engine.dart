import 'dart:async';
import 'dart:convert';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import '../models/vpn_status.dart';
import '../models/vpn_config.dart';

class VpnEngine {
  static final StreamController<String> _stageController =
      StreamController<String>.broadcast();
  static final StreamController<VpnStatus?> _statusController =
      StreamController<VpnStatus?>.broadcast();

  static late final FlutterV2ray _flutterV2Ray;
  static bool _isInitialized = false;
  static String _currentStage = vpnDisconnected;

  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";

  static Future<void> initialize() async {
    if (_isInitialized) return;
    _flutterV2Ray = FlutterV2ray(
      onStatusChanged: (status) {
        final stateStr = status.state.toLowerCase();
        if (stateStr == 'connected') {
          _currentStage = vpnConnected;
        } else if (stateStr == 'connecting') {
          _currentStage = vpnConnecting;
        } else {
          _currentStage = vpnDisconnected;
        }
        _stageController.add(_currentStage);

        _statusController.add(VpnStatus(
          duration: status.duration,
          byteIn: _formatSpeed(status.downloadSpeed),
          byteOut: _formatSpeed(status.uploadSpeed),
          lastPacketReceive: '0',
        ));
      },
    );

    await _flutterV2Ray.initializeV2Ray();
    _isInitialized = true;
  }

  static String _formatSpeed(int bytes) {
    if (bytes <= 0) return "0 KB/s";
    if (bytes < 1024) return "$bytes B/s";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB/s";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB/s";
  }

  static Stream<String> vpnStageSnapshot() => _stageController.stream;

  static Stream<VpnStatus?> vpnStatusSnapshot() => _statusController.stream;

  static Future<bool> startVpn(VpnConfig vpnConfig) async {
    await initialize();
    _stageController.add(vpnConnecting);

    final hasPermission = await _flutterV2Ray.requestPermission();
    if (!hasPermission) {
      _currentStage = vpnDenied;
      _stageController.add(vpnDenied);
      return false;
    }

    final optimizedConfig = optimizeV2rayConfig(vpnConfig.config);

    await _flutterV2Ray.startV2Ray(
      remark: vpnConfig.country,
      config: optimizedConfig,
      proxyOnly: false,
    );
    return true;
  }

  /// Enhances V2Ray configuration with robust DoH/TCP DNS resolvers and TLS/HTTP sniffing
  /// to eliminate 0 kbps issues, DNS blackholes, and local ISP censorship.
  static String optimizeV2rayConfig(String configJson) {
    if (configJson.isEmpty) return configJson;
    try {
      final dynamic decoded = jsonDecode(configJson);
      if (decoded is! Map<String, dynamic>) return configJson;
      final map = decoded;

      // 1. Inbounds: Enable sniffing with http & tls so SNI domains resolve correctly
      if (map.containsKey('inbounds') &&
          map['inbounds'] is List &&
          (map['inbounds'] as List).isNotEmpty) {
        final inbound = map['inbounds'][0] as Map<String, dynamic>;
        inbound['sniffing'] = {
          'enabled': true,
          'destOverride': ['http', 'tls'],
          'metadataOnly': false,
          'routeOnly': false,
        };
        if (inbound.containsKey('settings') && inbound['settings'] is Map) {
          inbound['settings']['udp'] = true;
        }
      }

      // 2. DNS: Provide fast, reliable DoH & public resolvers (Cloudflare + Google)
      // with localhost fallback to guarantee resolution even on UDP-restricted servers.
      map['dns'] = {
        'servers': [
          'https://1.1.1.1/dns-query',
          'https://dns.google/dns-query',
          '1.1.1.1',
          '8.8.8.8',
          '1.0.0.1',
          'localhost',
        ],
        'queryStrategy': 'UseIP',
      };

      // 3. Ensure direct freedom outbound is present
      if (map.containsKey('outbounds') && map['outbounds'] is List) {
        final List outbounds = map['outbounds'];
        bool hasDirect = outbounds.any((o) => o is Map && o['tag'] == 'direct');
        if (!hasDirect) {
          outbounds.add({
            'tag': 'direct',
            'protocol': 'freedom',
            'settings': {'domainStrategy': 'UseIp'},
          });
        }
      }

      // 4. Routing: Ensure geoip:private stays direct (LAN/Wi-Fi router local IP),
      // and foreign/internet traffic is routed through proxy with domain resolution.
      if (map.containsKey('routing') && map['routing'] is Map) {
        map['routing']['domainStrategy'] = 'IPIfNonMatch';
        final List rules = (map['routing']['rules'] as List? ?? []).toList();

        // Remove old port 53 hardcoded direct rule to prevent local ISP DNS hijacking
        rules.removeWhere((r) => r is Map && r['port'] == '53');

        // Keep private LAN IPs direct so local Wi-Fi / hotspots don't break
        rules.removeWhere((r) =>
            r is Map &&
            r['ip'] is List &&
            (r['ip'] as List).contains('geoip:private'));
        rules.insert(0, {
          'type': 'field',
          'ip': ['geoip:private'],
          'outboundTag': 'direct',
        });

        map['routing']['rules'] = rules;
      }

      return jsonEncode(map);
    } catch (_) {
      return configJson;
    }
  }

  static Future<void> stopVpn() async {
    if (!_isInitialized) return;
    await _flutterV2Ray.stopV2Ray();
    _currentStage = vpnDisconnected;
    _stageController.add(vpnDisconnected);
    _statusController.add(VpnStatus(
      duration: '00:00:00',
      byteIn: '0 B/s',
      byteOut: '0 B/s',
      lastPacketReceive: '0',
    ));
  }

  static Future<int> testDelay(String config) async {
    await initialize();
    try {
      return await _flutterV2Ray
          .getServerDelay(config: config)
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => -1);
    } catch (_) {
      return -1;
    }
  }

  static Future<String?> stage() async => _currentStage;

  static Future<bool> isConnected() async => _currentStage == vpnConnected;
}
