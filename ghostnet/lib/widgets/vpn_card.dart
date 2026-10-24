import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../helpers/prefs.dart';
import '../main.dart';
import '../models/vpn.dart';

class VpnCard extends StatefulWidget {
  final List<Vpn> vpnList;

  const VpnCard({Key? key, required this.vpnList}) : super(key: key);

  @override
  _VpnCardState createState() => _VpnCardState();
}

class _VpnCardState extends State<VpnCard> {
  bool showAllVpns = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    // Sort servers in this country by highest speed first
    widget.vpnList.sort((a, b) => b.speed.compareTo(a.speed));

    return Container(
      margin: EdgeInsets.symmetric(vertical: mediaQuery.height * .006),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      width: mediaQuery.width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * .04),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: showAllVpns
                      ? widget.vpnList.length
                      : min(widget.vpnList.length, 4),
                  itemBuilder: (context, index) {
                    final vpn = widget.vpnList[index];
                    final pingVal = int.tryParse(vpn.ping) ?? 45;

                    return ListTile(
                      onTap: () {
                        Get.back();
                        controller.switchServer(vpn);
                      },
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: Container(
                          padding: EdgeInsets.all(.5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(5)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: vpn.countryShort.toLowerCase() == 'auto'
                                ? Container(
                                    height: 32,
                                    width: 48,
                                    color: Colors.blueAccent.withOpacity(0.15),
                                    child: Icon(Icons.bolt_rounded,
                                        color: Colors.blueAccent, size: 20),
                                  )
                                : Image.asset(
                                    'assets/flags/${vpn.countryShort.toLowerCase()}.png',
                                    height: 32,
                                    width: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                      height: 32,
                                      width: 48,
                                      color: Colors.blueGrey.withOpacity(0.2),
                                      child: Icon(Icons.public,
                                          color: Colors.blueAccent, size: 20),
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          vpn.remark.isNotEmpty ? vpn.remark : vpn.countryLong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vpn.protocol,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.speed_rounded, color: Colors.blue, size: 14),
                            SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                _formatBytes(vpn.speed, 1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              size: 15,
                              color: pingVal < 80 ? Colors.green : Colors.amber,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '${vpn.ping} ms',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: pingVal < 80 ? Colors.green : Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                ),
                if (widget.vpnList.length > 4)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!showAllVpns)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showAllVpns = true;
                            });
                          },
                          child: Text(
                            'See More',
                            style: TextStyle(
                                color: Pref.isDarkMode ? Colors.white : Colors.black),
                          ),
                        )
                      else
                        TextButton(
                          onPressed: () {
                            setState(() {
                              showAllVpns = false;
                            });
                          },
                          child: Text('Hide'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
