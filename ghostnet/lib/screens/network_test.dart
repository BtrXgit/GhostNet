import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../apis/apis.dart';
import '../main.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../widgets/network_card.dart';

class NetworkInformation extends StatelessWidget {
  const NetworkInformation({super.key});

  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;
    APIs.getIPDetails(ipData: ipData);

    return Scaffold(
      //refresh button
      backgroundColor: Theme.of(context).backgroundColour,
      body: Stack(
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationX(3.141592653589793),
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
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                width: mediaQuery.width,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: mediaQuery.width * .04),
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
                                'Network Details',
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
              Obx(
                () => Expanded(
                  child: ListView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                          left: mediaQuery.width * .04,
                          right: mediaQuery.width * .04,
                          top: mediaQuery.height * .01,
                          bottom: mediaQuery.height * .1),
                      children: [
                        //ip
                        NetworkCard(
                            data: NetworkData(
                                title: 'IP Address',
                                subtitle: ipData.value.query,
                                icon: Icon(CupertinoIcons.location_solid,
                                    color: Colors.blue))),

                        //isp
                        NetworkCard(
                            data: NetworkData(
                                title: 'Internet Provider',
                                subtitle: ipData.value.isp,
                                icon: Icon(Icons.business,
                                    color: Colors.orange))),

                        //location
                        NetworkCard(
                            data: NetworkData(
                                title: 'Location',
                                subtitle: ipData.value.country.isEmpty
                                    ? 'Fetching ...'
                                    : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                                icon: Icon(CupertinoIcons.location,
                                    color: Colors.pink))),

                        //pin code
                        NetworkCard(
                            data: NetworkData(
                                title: 'Pin-code',
                                subtitle: ipData.value.zip,
                                icon: Icon(CupertinoIcons.location_solid,
                                    color: Colors.cyan))),

                        //timezone
                        NetworkCard(
                            data: NetworkData(
                                title: 'Timezone',
                                subtitle: ipData.value.timezone,
                                icon: Icon(CupertinoIcons.time,
                                    color: Colors.green))),
                      ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
