import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:get/get.dart';
import 'package:ciphercloak/main.dart';
import '../apis/apis.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/prefs.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to VPN connection stages
    VpnEngine.vpnStageSnapshot().listen(onVpnStageChanged);
    autoFetchServers();
  }

  void onVpnStageChanged(String stage) {
    vpnState.value = stage;
    log('VPN Stage: $stage');
  }

  Future<void> autoFetchServers() async {
    final list = await APIs.getVPNServers();
    if (list.isNotEmpty) {
      final isCurrentInList = list.any((s) => s.rawUrl == vpn.value.rawUrl);
      if (vpn.value.v2rayConfig.isEmpty || vpn.value.rawUrl.isEmpty || !isCurrentInList) {
        vpn.value = list.first;
        Pref.vpn = list.first;
      }
    }
  }

  Future<void> switchServer(Vpn newVpn) async {
    vpn.value = newVpn;
    Pref.vpn = newVpn;
    if (vpnState.value != VpnEngine.vpnDisconnected) {
      await VpnEngine.stopVpn();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    _startConnecting();
  }

  void connectToVpn() async {
    if (vpn.value.v2rayConfig.isEmpty && vpn.value.rawUrl.isEmpty) {
      OverseasDialogs.info(msg: 'Select a Location to Connect to VPN');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      _startConnecting();
    } else {
      await VpnEngine.stopVpn();
    }
  }

  void _startConnecting() async {
    try {
      vpnState.value = VpnEngine.vpnConnecting;

      Vpn targetVpn = vpn.value;

      // 1. If Smart Connect is selected, dynamically pick the lowest-latency live server
      if (targetVpn.countryShort == 'AUTO' || targetVpn.rawUrl == 'smart://connect') {
        final fastest = await _findFastestLiveServer();
        if (fastest != null) {
          targetVpn = fastest;
        }
      }

      String config = targetVpn.v2rayConfig;
      if (config.isEmpty && targetVpn.rawUrl.isNotEmpty && targetVpn.rawUrl != 'smart://connect') {
        try {
          final parser = FlutterV2ray.parseFromURL(targetVpn.rawUrl);
          config = parser.getFullConfiguration();
          targetVpn.v2rayConfig = config;
          vpn.value = targetVpn;
        } catch (_) {}
      }

      // 2. Pre-connection health verification: test if server responds
      int delay = -1;
      if (config.isNotEmpty) {
        delay = await VpnEngine.testDelay(config);
      }

      // 3. If target node is dead or unresponsive, seamlessly failover to best active alternative!
      if (delay < 0) {
        log('Selected server (${targetVpn.remark}) is unreachable. Auto-failing over to active server...');
        final alternative = await _findActiveAlternative(targetVpn.countryLong);
        if (alternative != null) {
          targetVpn = alternative;
          config = targetVpn.v2rayConfig;
          vpn.value = targetVpn;
          Pref.vpn = targetVpn;
        }
      } else {
        targetVpn.ping = delay.toString();
        vpn.value = targetVpn;
      }

      final vpnConfig = VpnConfig(
        country: targetVpn.remark.isNotEmpty ? targetVpn.remark : targetVpn.countryLong,
        username: '',
        password: '',
        config: config,
      );

      final success = await VpnEngine.startVpn(vpnConfig);
      if (!success) {
        OverseasDialogs.error(msg: 'VPN permission denied or server unavailable.');
      }
    } catch (e) {
      log('Error starting VPN: $e');
      OverseasDialogs.error(msg: 'Failed to connect: $e');
      await VpnEngine.stopVpn();
    }
  }

  Future<Vpn?> _findFastestLiveServer() async {
    final list = Pref.vpnList.where((s) => s.rawUrl != 'smart://connect').toList();
    if (list.isEmpty) return null;

    Vpn? best;
    int lowestDelay = 99999;

    // Test top candidate nodes (up to 12 across priority locations)
    final candidates = list.take(12).toList();
    for (var candidate in candidates) {
      String cfg = candidate.v2rayConfig;
      if (cfg.isEmpty && candidate.rawUrl.isNotEmpty) {
        try {
          cfg = FlutterV2ray.parseFromURL(candidate.rawUrl).getFullConfiguration();
          candidate.v2rayConfig = cfg;
        } catch (_) {}
      }

      if (cfg.isNotEmpty) {
        final d = await VpnEngine.testDelay(cfg);
        if (d >= 0 && d < lowestDelay) {
          lowestDelay = d;
          candidate.ping = d.toString();
          best = candidate;
          if (lowestDelay < 80) break; // Fast enough, connect immediately!
        }
      }
    }

    return best ?? (list.isNotEmpty ? list.first : null);
  }

  Future<Vpn?> _findActiveAlternative(String countryLong) async {
    final list = Pref.vpnList.where((s) => s.rawUrl != 'smart://connect').toList();
    if (list.isEmpty) return null;

    // 1. Try other servers in the same country
    final sameCountry = list
        .where((s) => s.countryLong == countryLong && s.rawUrl != vpn.value.rawUrl)
        .toList();

    for (var candidate in sameCountry) {
      String cfg = candidate.v2rayConfig;
      if (cfg.isEmpty && candidate.rawUrl.isNotEmpty) {
        try {
          cfg = FlutterV2ray.parseFromURL(candidate.rawUrl).getFullConfiguration();
          candidate.v2rayConfig = cfg;
        } catch (_) {}
      }
      if (cfg.isNotEmpty) {
        final d = await VpnEngine.testDelay(cfg);
        if (d >= 0) {
          candidate.ping = d.toString();
          return candidate;
        }
      }
    }

    // 2. Global fallback: Try top servers in neighboring or high-speed regions
    final fallbackPriority = [
      'Singapore',
      'India',
      'Germany',
      'United States',
      'United Kingdom',
      'Japan',
      'Netherlands',
    ];

    for (var country in fallbackPriority) {
      final candidates = list.where((s) => s.countryLong == country).take(2);
      for (var candidate in candidates) {
        String cfg = candidate.v2rayConfig;
        if (cfg.isEmpty && candidate.rawUrl.isNotEmpty) {
          try {
            cfg = FlutterV2ray.parseFromURL(candidate.rawUrl).getFullConfiguration();
            candidate.v2rayConfig = cfg;
          } catch (_) {}
        }
        if (cfg.isNotEmpty) {
          final d = await VpnEngine.testDelay(cfg);
          if (d >= 0) {
            candidate.ping = d.toString();
            return candidate;
          }
        }
      }
    }

    return null;
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.red;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Pref.isDarkMode ? const Color(0xFFDCE2FA) : const Color(0xff131321);
    }
  }

  // vpn button text
  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Tap to Connect';

      case VpnEngine.vpnConnected:
        return 'Disconnect';

      default:
        return 'Connecting...';
    }
  }
}
