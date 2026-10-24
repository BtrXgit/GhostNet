import 'dart:convert';
import 'package:flutter_v2ray/flutter_v2ray.dart';

void main() {
  final ss = FlutterV2ray.parseFromURL(
    'ss://YWVzLTI1Ni1nY206WlJwZ2FCZUd4dEVOSVhndmhwa1pCS3o5R25XUlMyZFljeDlPK2EyaXdOND0=@185.176.206.9:19999#Test'
  );
  final fullConfigStr = ss.getFullConfiguration();
  final map = jsonDecode(fullConfigStr);
  
  // Add dns-out outbound
  final outbounds = map['outbounds'] as List;
  outbounds.add({
    "tag": "dns-out",
    "protocol": "dns",
  });
  
  // Add routing rule for port 53
  final routing = map['routing'] as Map<String, dynamic>;
  final rules = (routing['rules'] as List? ?? []);
  rules.insert(0, {
    "type": "field",
    "port": "53",
    "outboundTag": "dns-out"
  });
  routing['rules'] = rules;
  
  map['dns'] = {
    "servers": [
      "https+local://1.1.1.1/dns-query",
      "https+local://8.8.8.8/dns-query",
      "1.1.1.1",
      "8.8.8.8"
    ]
  };

  print("Config valid JSON: ${jsonEncode(map).length} bytes");
  print(jsonEncode(routing));
  print(jsonEncode(map['dns']));
}
