import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ciphercloak/helpers/prefs.dart';
import 'package:ciphercloak/main.dart';
import 'package:ciphercloak/screens/privacy_policy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
      'CipherCloak',
      style: GoogleFonts.orbitron(fontSize: 42, color: Colors.white),
    );
    title = title
        .animate(adapter: ValueAdapter(0.5))
        .shimmer(colors: [Colors.white, Colors.black, Colors.grey]);

    title = title
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .saturate(
          delay: NumDurationExtensions(1).seconds,
          duration: NumDurationExtensions(2).seconds,
        )
        .then()
        .tint(color: Theme.of(context).primaryColour)
        .then();

    return Scaffold(
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
          SingleChildScrollView(
            controller: ScrollController(),
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Column(
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
                                  'Settings',
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  title,
                  const SizedBox(height: 20),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: mediaQuery.height * .006,
                      horizontal: 20,
                    ),
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
                            horizontal: mediaQuery.width * .04,
                          ),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Iconsax.paintbucket,
                                  size: 28,
                                ),
                                title: const Text('Change Theme'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sunny,
                                      color: Pref.isDarkMode
                                          ? null
                                          : Colors.yellow,
                                    ),
                                    Switch(
                                      activeColor: Pref.isDarkMode
                                          ? Colors.white
                                          : Color(0xff131321),
                                      value: Pref.isDarkMode,
                                      onChanged: (bool value) {
                                        Get.changeThemeMode(
                                          value
                                              ? ThemeMode.dark
                                              : ThemeMode.light,
                                        );
                                        Pref.isDarkMode = value;
                                      },
                                    ),
                                    Icon(
                                      Icons.nightlight_round,
                                      color: Pref.isDarkMode
                                          ? Colors.white
                                          : null,
                                    ),
                                  ],
                                ),
                                iconColor: Theme.of(context).primaryColour,
                                textColor: Theme.of(context).primaryColour,
                                onTap: () {
                                  _showAboutAppBottomSheet(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Iconsax.info_circle,
                                  size: 28,
                                ),
                                title: const Text('About'),
                                subtitle: Text(
                                  'Find out more about CipherCloak',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                iconColor: Theme.of(context).primaryColour,
                                textColor: Theme.of(context).primaryColour,
                                onTap: () {
                                  _showAboutAppBottomSheet(context);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Iconsax.activity, size: 28),
                                title: const Text('Changelog'),
                                subtitle: const Text(
                                  'Recent improvements and fixes',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                iconColor: Theme.of(context).primaryColour,
                                textColor: Theme.of(context).primaryColour,
                                onTap: () {
                                  _showChangelogPopup(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: mediaQuery.height * .006,
                      horizontal: 20,
                    ),
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
                            horizontal: mediaQuery.width * .04,
                          ),
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
                              ListTile(
                                leading: const Icon(Iconsax.bookmark, size: 28),
                                title: const Text('Liscenses'),
                                subtitle: const Text(
                                  'View open source liscenses',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                iconColor: Theme.of(context).primaryColour,
                                textColor: Theme.of(context).primaryColour,
                                onTap: () {
                                  showLicensePage(
                                    context: context,
                                  ); // Show the licenses page
                                },
                              ),
                              ListTile(
                                leading: const Icon(Iconsax.document),
                                title: const Text('Privacy Policy'),
                                subtitle: const Text(
                                  'CipherCloak privacy policy',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                iconColor: Theme.of(context).primaryColour,
                                textColor: Theme.of(context).primaryColour,
                                onTap: () {
                                  Get.to(const PrivacyPage());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Text(
                  'CipherCloak v 1.0.0',
                  style: GoogleFonts.kanit(
                    color: Theme.of(context).primaryColour,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'By XD',
                  style: GoogleFonts.kanit(
                    color: Theme.of(context).primaryColour,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutAppBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1E1E2A),
          content: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'About the App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '🔒 Protect your online privacy with GhostVPN - the premier VPN app. Explore a wide range of secure servers across the globe, ensuring anonymous and encrypted browsing. With an easy-to-use interface, GhostVPN offers seamless protection for your digital activities. Safeguard your data and access restricted content with confidence. 🌐🔒',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'Version: 1.0.0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _showChangelogPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E1E2A),
        content: Container(
          padding: const EdgeInsets.all(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🚀 CipherCloak Initial Release',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ChangelogEntry extends StatelessWidget {
  final String version;
  final String date;
  final List<String> changes;

  const ChangelogEntry({
    super.key,
    required this.version,
    required this.date,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Version $version',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Released on $date',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: changes.map((change) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    change,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
