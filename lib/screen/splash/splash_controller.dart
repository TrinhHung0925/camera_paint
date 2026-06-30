import 'package:get/get.dart';

import '../../route.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _autoNext();
  }

  /// Sau 5s tự động chuyển sang màn intro (PageView).
  Future<void> _autoNext() async {
    await Future.delayed(const Duration(seconds: 5));
    if (isClosed) return;
    Get.offNamed(AppPage.home.routeName);
  }
}
