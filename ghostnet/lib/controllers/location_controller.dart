import 'package:get/get.dart';
import '../apis/apis.dart';
import '../helpers/prefs.dart';
import '../models/vpn.dart';
import '../services/vpn_engine.dart';

class LocationController extends GetxController {
  final RxList<Vpn> vpnList = <Vpn>[...Pref.vpnList].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (vpnList.isEmpty) {
      getVpnData();
    }
  }

  Future<void> getVpnData() async {
    isLoading.value = true;
    final res = await APIs.getVPNServers();
    vpnList.assignAll(res);
    isLoading.value = false;
  }

  Future<void> pingServer(Vpn vpn) async {
    if (vpn.rawUrl == 'smart://connect') {
      vpn.ping = '15';
      return;
    }
    if (vpn.v2rayConfig.isNotEmpty) {
      final delay = await VpnEngine.testDelay(vpn.v2rayConfig);
      if (delay >= 0) {
        vpn.ping = delay.toString();
        final idx = vpnList.indexOf(vpn);
        if (idx != -1) {
          vpnList[idx] = vpn;
        }
      }
    }
  }
}
