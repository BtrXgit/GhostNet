class Vpn {
  late String hostname;
  late String ip;
  late String ping;
  late int speed;
  late String countryLong;
  late String countryShort;
  late int numVpnSessions;
  late String rawUrl;
  late String v2rayConfig;
  late String protocol;
  late String remark;

  Vpn({
    this.hostname = '',
    this.ip = '',
    this.ping = '0',
    this.speed = 0,
    required this.countryLong,
    required this.countryShort,
    this.numVpnSessions = 0,
    this.rawUrl = '',
    this.v2rayConfig = '',
    this.protocol = 'VLESS',
    this.remark = '',
  });

  Vpn.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? json['hostname'] ?? '';
    ip = json['IP'] ?? json['ip'] ?? '';
    ping = (json['Ping'] ?? json['ping'] ?? '0').toString();
    speed = json['Speed'] ?? json['speed'] ?? 0;
    countryLong = json['CountryLong'] ?? json['countryLong'] ?? '';
    countryShort = json['CountryShort'] ?? json['countryShort'] ?? '';
    numVpnSessions = json['NumVpnSessions'] ?? json['numVpnSessions'] ?? 0;
    rawUrl = json['rawUrl'] ?? json['OpenVPN_ConfigData_Base64'] ?? '';
    v2rayConfig = json['v2rayConfig'] ?? '';
    protocol = json['protocol'] ?? 'VLESS';
    remark = json['remark'] ?? (countryLong.isNotEmpty ? countryLong : 'Fast Server');
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['CountryLong'] = countryLong;
    data['CountryShort'] = countryShort;
    data['NumVpnSessions'] = numVpnSessions;
    data['rawUrl'] = rawUrl;
    data['v2rayConfig'] = v2rayConfig;
    data['protocol'] = protocol;
    data['remark'] = remark;
    return data;
  }
}
