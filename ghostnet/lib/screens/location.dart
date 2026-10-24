import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/location_controller.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  LocationScreen({Key? key}) : super(key: key);

  final _controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {

    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).backgroundColour,
        body: Stack(
          children: [
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.141592653589793),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/dot.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  height: mediaQuery.height * 0.12,
                  decoration: BoxDecoration(color: Colors.transparent),
                  width: mediaQuery.width,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: mediaQuery.width * .04,
                        ),
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Servers (${_controller.vpnList.length})',
                                style: GoogleFonts.orbitron(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _controller.isLoading.value
                      ? _loadingWidget()
                      : _controller.vpnList.isEmpty
                      ? _noVPNFound()
                      : _vpnData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vpnData() {
    final sortedList = [..._controller.vpnList]..sort((a, b) => a.countryLong.compareTo(b.countryLong));
    final groupedVpnList = _groupVpnsByCountry(sortedList);

    return RefreshIndicator(
      onRefresh: () => _controller.getVpnData(),
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: mediaQuery.height * .015,
          bottom: mediaQuery.height * .1,
          left: mediaQuery.width * .04,
          right: mediaQuery.width * .04,
        ),
        itemCount: groupedVpnList.length,
        itemBuilder: (context, index) {
          return VpnCard(vpnList: groupedVpnList[index]);
        },
      ),
    );
  }

  List<List<Vpn>> _groupVpnsByCountry(List<Vpn> vpnList) {
    final Map<String, List<Vpn>> groupedVpns = {};

    for (var vpn in vpnList) {
      groupedVpns.putIfAbsent(vpn.countryLong, () => []).add(vpn);
    }

    final priorityOrder = [
      '⚡ Smart Connect',
      'India',
      'Singapore',
      'United States',
      'Germany',
      'United Kingdom',
      'Japan',
      'South Korea',
      'Canada',
      'France',
      'Netherlands',
      'United Arab Emirates',
      'Australia',
      'Hong Kong',
      'Turkey',
      'Switzerland',
      'Italy',
      'Spain',
      'Poland',
      'Finland',
      'Austria',
      'Romania',
      'Indonesia',
      'Thailand',
      'Taiwan',
      'Vietnam',
      'South Africa',
      'Armenia',
      'Estonia',
      'Latvia',
    ];

    final List<List<Vpn>> result = [];
    for (var country in priorityOrder) {
      if (groupedVpns.containsKey(country)) {
        result.add(groupedVpns.remove(country)!);
      }
    }
    // Append any remaining countries
    result.addAll(groupedVpns.values);
    return result;
  }

  Widget _loadingWidget() => SizedBox(
    width: double.infinity,
    height: double.infinity,
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _noVPNFound() => Center(
    child: Text(
      'OOPs, No VPN Found',
      style: TextStyle(
        fontSize: 18,
        color: Colors.black54,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
