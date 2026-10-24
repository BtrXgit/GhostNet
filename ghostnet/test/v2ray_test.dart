import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

void main() {
  test('verify FlutterV2ray parser', () {
    const testUrl = "vless://e75ad2eb-6c1f-45ce-8023-f5f10875df66@205.237.110.254:443?pbk=IG6lxrx_xkGOoBuo3DC8sgQoIFmqVgznIr0qOuNO0w4&security=reality&fm=AhmadV2ray&type=tcp&sni=zsit.eu-cdn294.com&flow=xtls-rprx-vision&headerType=none&encryption=none&sid=cd2d53510b4df2a8&fp=chrome&spx=/AhmadV2ray#United+States";
    
    final parser = FlutterV2ray.parseFromURL(testUrl);
    expect(parser.remark, isNotEmpty);
    expect(parser.getFullConfiguration(), isNotEmpty);
    print('Parsed remark: ${parser.remark}');
    print('CONFIG JSON:\n${parser.getFullConfiguration()}');
  });

  test('verify Indian V2Ray URLs parsing', () {
    final urls = [
      "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@150.40.126.22:443?mode=gun&security=reality&encryption=none&authority=BIA_TELEGRAM&pbk=sXsJ4ET-50TYqlhKZf03nPQr2JIy1F0D4m6lOsI0cAs&fp=firefox&type=grpc&serviceName=media.v1.StreamService&sni=rs4.univesalsrv.com&sid=861ac7d66953e55f#🇮🇳+India+Mumbai+01",
      "vless://1d4e18bd-1f26-4915-b35a-7ace4826e76a@194.61.31.126:2053?security=reality&encryption=none&pbk=PuAGLfJy6cu1TNoHuKIKSxPetCbZI41fc8hQDjWPIAU&headerType=&fp=chrome&type=tcp&sni=www.apple.com&sid=9980e0609b0d3891#🇮🇳+India+Mumbai+Reality+02",
      "vless://1443b7a1-7ba9-4ec9-b904-2e867367b5d7@104.21.69.118:443?path=/sync&security=tls&encryption=none&insecure=0&host=odd-violet-5440.asdgrweeee13.workers.dev&fp=chrome&type=ws&allowInsecure=0&sni=odd-violet-5440.asdgrweeee13.workers.dev#🇮🇳+India+Delhi+Cloud+01",
      "vless://511c1563-2cb6-4064-abc6-a59ee49818a8@5.253.30.99:40443?security=reality&encryption=none&pbk=cwmcqsfS7klQlkcoUNuATEk0NiPY-NnRb9z8rCJDQw0&headerType=none&fp=chrome&spx=/&type=tcp&flow=xtls-rprx-vision&sni=deepl.com&sid=88b6#🇮🇳+India+Bangalore+Ultra+01",
      "vless://af5eac96-e478-488a-bc8c-45269d7e8847@dorado.yokkastars.com:40443?security=reality&encryption=none&pbk=g77ZJbm18JEotapmVRjaXi133MzkbhkU2lxhVeXx8zw&headerType=none&fp=chrome&type=tcp&flow=xtls-rprx-vision&sni=deepl.com&sid=68a8#🇮🇳+India+Chennai+Edge+01",
      "vless://2f35965a-9a9b-45fd-ba32-987296dfb6be@150.40.126.22:443?mode=gun&security=reality&encryption=none&authority=BIA_TELEGRAM&pbk=sXsJ4ET-50TYqlhKZf03nPQr2JIy1F0D4m6lOsI0cAs&fp=firefox&type=grpc&serviceName=media.v1.StreamService&sni=rs4.univesalsrv.com&sid=861ac7d66953e55f#🇮🇳+India+Hyderabad+Direct+01",
      "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpFQkRSbzlUSHg0Q3FpRlU3aDVnZm92NzZvTnd6WlVSQWgwWndiV2pCS2RkdFVodno@103.120.178.193:31348#🇮🇳+India+Fast+SS",
      "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpURkVsRzJGVnF5cUc@176.97.64.144:8388#Singapore+🇸🇬",
      "vless://39947382-3212-41c9-bc3a-589574ac8b23@uae.unixzone.us:22573?encryption=none&security=none&type=ws&host=uae.unixzone.us&path=/#🇦🇪+UAE+Dubai",
      "ss://YWVzLTEyOC1nY206c2hhZG93c29ja3M=@149.22.87.204:443#🇯🇵+Japan+Tokyo",
    ];

    for (var u in urls) {
      final p = FlutterV2ray.parseFromURL(u);
      expect(p.remark, isNotEmpty);
      expect(p.getFullConfiguration(), isNotEmpty);
    }
  });

  test('verify all bundled servers in assets/v2ray_servers.json parse cleanly', () {
    final file = File('assets/v2ray_servers.json');
    final content = file.readAsStringSync();
    final List list = jsonDecode(content);
    expect(list, isNotEmpty);
    print('Testing ${list.length} bundled servers from assets/v2ray_servers.json...');
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      final rawUrl = item['rawUrl'] as String;
      expect(rawUrl, isNotEmpty);
      try {
        final p = FlutterV2ray.parseFromURL(rawUrl);
        expect(p.getFullConfiguration(), isNotEmpty);
        count++;
      } catch (e) {
        print('FAILED server at index $i: ${item['countryLong']} | $rawUrl | Error: $e');
        rethrow;
      }
    }
    print('Successfully verified $count / ${list.length} servers!');
  });
}
