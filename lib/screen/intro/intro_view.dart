import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../resource/app_colors.dart';
import 'intro_controller.dart';
import 'pages/intro1.dart';
import 'pages/intro2.dart';
import 'pages/intro3.dart';
import 'pages/intro4.dart';
import 'pages/intro5.dart';
import 'pages/intro6.dart';
import 'pages/intro7.dart';
import 'pages/intro8.dart';
import 'pages/intro9.dart';
import 'pages/intro10.dart';
import 'pages/intro11.dart';
import 'pages/intro12.dart';
import 'pages/intro13.dart';

/// Màn Intro — PageView gồm 13 trang onboarding.
class IntroView extends StatefulWidget {
  IntroView({super.key}) {
    if (!Get.isRegistered<IntroController>()) {
      Get.put(IntroController());
    }
  }

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView> {
  final controller = Get.find<IntroController>();

  @override
  void dispose() {
    Get.delete<IntroController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ff0C0A07,
        body: PageView(
          controller: c.pageController,
          onPageChanged: c.onPageChanged,
          children: [
            Intro1(controller: c),
            Intro2(controller: c),
            Intro3(controller: c),
            Intro4(controller: c),
            Intro5(controller: c),
            Intro6(controller: c),
            Intro7(controller: c),
            Intro8(controller: c),
            Intro9(controller: c),
            Intro10(controller: c),
            Intro11(controller: c),
            Intro12(controller: c),
            Intro13(controller: c),
          ],
        ),
      ),
    );
  }
}
