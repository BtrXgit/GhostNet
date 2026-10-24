import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ciphercloak/screens/network_test.dart';
import 'package:ciphercloak/screens/settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/home_controller.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import 'location.dart';

class GhostHome extends StatelessWidget {
  GhostHome({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColour,
      // backgroundColor: Color.fromARGB(255, 22, 22, 26),

      //body
      body: Stack(
        children: [
          FadeInDown(
            child: Container(
              // height: mediaQuery.height * .4,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/dot.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: FadeIn(
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(200),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () => Get.to(SettingsPage(),
                                        transition: Transition.cupertino),
                                    icon: Icon(
                                      Iconsax.setting_3,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () => Get.to(NetworkInformation(),
                                transition: Transition.cupertino),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
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
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => Get.to(
                                                NetworkInformation(),
                                                transition:
                                                    Transition.cupertino),
                                            icon: Icon(
                                              Iconsax.info_circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            "Information",
                                            style: GoogleFonts.openSans(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: mediaQuery.height * .08,
                    ),
                    ElasticIn(
                      child: Text(
                        'CipherCloak',
                        style: GoogleFonts.orbitron(
                          color: Theme.of(context).primaryColour,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mediaQuery.height * .04,
                    ),
                    Obx(
                      () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _controller.vpnState.value ==
                                    VpnEngine.vpnDisconnected
                                ? 'Not Connected'
                                : _controller.vpnState
                                    .replaceAll('_', ' ')
                                    .toUpperCase(),
                            style: GoogleFonts.kanit(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          CountDownTimer(
                              startTimer: _controller.vpnState.value ==
                                  VpnEngine.vpnConnected)
                        ],
                      ),
                    ),
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Container(
                          height: 70,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: mediaQuery.width * .04),
                                  height: 70,
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
                                  child: _changeLocation(context)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
          Obx(
            () => Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: ElasticIn(
                    delay: Duration(milliseconds: 800), child: _vpnButton())),
          ),
          Positioned(
            bottom: 0,
            child: FadeInUp(
              child: Container(
                height: mediaQuery.height * 0.22,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                width: mediaQuery.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: mediaQuery.height * 0.22,
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
                      child: StreamBuilder<VpnStatus?>(
                        initialData: VpnStatus(),
                        stream: VpnEngine.vpnStatusSnapshot(),
                        builder: (context, snapshot) => Padding(
                          padding: const EdgeInsets.fromLTRB(0, 24, 0, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //download
                              Container(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.lightGreen,
                                      child: Icon(Iconsax.arrow_down_2,
                                          size: 30, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      '${snapshot.data?.byteIn ?? '0 kbps'}',
                                      style: GoogleFonts.kanit(
                                        color: Theme.of(context).primaryColour,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Download',
                                      style: GoogleFonts.kanit(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                              ),

                              Container(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.blue,
                                      child: Icon(Iconsax.arrow_up_1,
                                          size: 30, color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      '${snapshot.data?.byteOut ?? '0 kbps'}',
                                      style: GoogleFonts.kanit(
                                        color: Theme.of(context).primaryColour,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Upload',
                                      style: GoogleFonts.kanit(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Obx(() => Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: FadeInUp(child: _mainVPNButton()))),
        ],
      ),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: Container(
              padding: EdgeInsets.all(38),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _controller.getButtonColor.withOpacity(.1)),
              child: Container(
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.2)),
                child: Container(
                  padding: EdgeInsets.all(38),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    padding: EdgeInsets.all(36),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor.withOpacity(.4)),
                    child: Container(
                      padding: EdgeInsets.all(34),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _controller.getButtonColor.withOpacity(.5)),
                      // child: Container(
                      //   width: mediaQuery.height * .8,
                      //   height: mediaQuery.height * .8,
                      //   decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: _controller.getButtonColor),
                      // ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _mainVPNButton() {
    return InkWell(
      onTap: () {
        _controller.connectToVpn();
      },
      child: Container(
        width: mediaQuery.height * .14,
        height: mediaQuery.height * .14,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: _controller.getButtonColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //icon
            Icon(
              Icons.power_settings_new,
              size: 28,
              color: Colors.white,
            ),

            SizedBox(height: 4),

            //text
            Text(
              _controller.getButtonText,
              style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _changeLocation(BuildContext context) => Semantics(
        button: true,
        child: InkWell(
          onTap: () =>
              Get.to(() => LocationScreen(), transition: Transition.cupertino),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueAccent,
                child: (_controller.vpn.value.countryLong.isEmpty ||
                        _controller.vpn.value.countryShort.toLowerCase() == 'auto')
                    ? Icon(Icons.bolt_rounded, size: 24, color: Colors.white)
                    : null,
                backgroundImage: (_controller.vpn.value.countryLong.isEmpty ||
                        _controller.vpn.value.countryShort.toLowerCase() == 'auto')
                    ? null
                    : AssetImage(
                        'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
              ),

              //for adding some space
              SizedBox(width: 10),

              //text
              Expanded(
                child: Text(
                  _controller.vpn.value.countryLong.isEmpty
                      ? 'Select Location'
                      : _controller.vpn.value.countryLong,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(width: 8),
              Icon(Icons.equalizer_rounded, size: 26, color: Colors.white),
              Text(
                _controller.vpn.value.countryLong.isEmpty
                    ? '100 ms'
                    : '${_controller.vpn.value.ping} ms',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                width: 8,
              ),
              //icon
              Icon(Iconsax.arrow_right_2, color: Colors.white, size: 26)
            ],
          ),
        ),
      );
}
