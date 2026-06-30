import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../resource/app_colors.dart';
import '../../resource/app_text.dart';
import '../../route.dart';
import 'home_controller.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key}) {
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController());
    }
  }

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var controller = Get.find<HomeController>();

  @override
  void dispose() {
    Get.delete<HomeController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ffFFFFFF,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Home', style: AppText.bold20),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppPage.draw.routeName),
              child: Text('Mở màn vẽ', style: AppText.medium16),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: () => Get.toNamed(AppPage.game.routeName),
              child: Text('🍉 Play game', style: AppText.medium16),
            ),
          ],
        ),
      ),
    );
  }
}
