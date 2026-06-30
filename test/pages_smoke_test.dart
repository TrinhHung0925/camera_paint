// Quét từng trang intro: pump ở 390x844 và báo trang nào throw/overflow.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:camera_paint/screen/intro/intro_controller.dart';
import 'package:camera_paint/screen/intro/pages/intro1.dart';
import 'package:camera_paint/screen/intro/pages/intro2.dart';
import 'package:camera_paint/screen/intro/pages/intro3.dart';
import 'package:camera_paint/screen/intro/pages/intro4.dart';
import 'package:camera_paint/screen/intro/pages/intro5.dart';
import 'package:camera_paint/screen/intro/pages/intro6.dart';
import 'package:camera_paint/screen/intro/pages/intro7.dart';
import 'package:camera_paint/screen/intro/pages/intro8.dart';
import 'package:camera_paint/screen/intro/pages/intro9.dart';
import 'package:camera_paint/screen/intro/pages/intro10.dart';
import 'package:camera_paint/screen/intro/pages/intro11.dart';
import 'package:camera_paint/screen/intro/pages/intro12.dart';
import 'package:camera_paint/screen/intro/pages/intro13.dart';

final builders = <String, Widget Function(IntroController)>{
  'intro1': (c) => Intro1(controller: c),
  'intro2': (c) => Intro2(controller: c),
  'intro3': (c) => Intro3(controller: c),
  'intro4': (c) => Intro4(controller: c),
  'intro5': (c) => Intro5(controller: c),
  'intro6': (c) => Intro6(controller: c),
  'intro7': (c) => Intro7(controller: c),
  'intro8': (c) => Intro8(controller: c),
  'intro9': (c) => Intro9(controller: c),
  'intro10': (c) => Intro10(controller: c),
  'intro11': (c) => Intro11(controller: c),
  'intro12': (c) => Intro12(controller: c),
  'intro13': (c) => Intro13(controller: c),
};

void main() {
  builders.forEach((name, build) {
    testWidgets('renders $name', (tester) async {
      Get.testMode = true;
      final c = Get.put(IntroController(), tag: name);
      addTearDown(() => Get.delete<IntroController>(tag: name));

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 884),
          builder: (context, _) => MaterialApp(home: build(c)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$name threw');
    });
  });
}
