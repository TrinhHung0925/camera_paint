// Smoke tests: Splash tự động sang Intro; Intro PageView render 2 trang.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:camera_paint/route.dart';
import 'package:camera_paint/screen/intro/intro_controller.dart';
import 'package:camera_paint/screen/intro/intro_view.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  testWidgets('Splash auto-advances to Intro after 5s', (tester) async {
    tester.view.physicalSize = const Size(390, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, _) => GetMaterialApp(
          initialRoute: AppPage.splash.routeName,
          onGenerateRoute: generateRoute,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Plan Trips'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6)); // qua mốc 5s
    await tester.pump();
    expect(find.text('Start Planning'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Intro PageView renders Hook then Problem', (tester) async {
    tester.view.physicalSize = const Size(390, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 884),
        builder: (context, _) => GetMaterialApp(home: IntroView()),
      ),
    );
    await tester.pump();
    expect(find.text('Start Planning'), findsOneWidget);

    // Sang trang 2. Dùng pump theo thời gian (không pumpAndSettle) vì trang
    // hook có nền cross-fade chạy nền (timer lặp) sẽ khiến pumpAndSettle treo.
    Get.find<IntroController>().next();
    await tester.pump(); // bắt đầu chuyển trang
    await tester.pump(const Duration(milliseconds: 900)); // qua transition + reveal
    expect(find.text('THE PROBLEM'), findsOneWidget);
    expect(find.text('Show Me'), findsOneWidget);
    expect(find.text('Day 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
