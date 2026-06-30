import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../route.dart';

class IntroController extends GetxController {
  final pageController = PageController();

  /// Tổng số trang onboarding trong PageView.
  static const int pageCount = 13;

  int page = 0;
  int get lastIndex => pageCount - 1;

  /// Loại du khách người dùng chọn ở intro7 (dùng lại ở intro8 "Tuned for ...").
  String travelerType = 'Food Explorer';
  String travelerEmoji = '🍜';

  void setTraveler(String type, String emoji) {
    travelerType = type;
    travelerEmoji = emoji;
  }

  void onPageChanged(int index) {
    page = index;
    update();
  }

  /// Sang trang kế; ở trang cuối thì kết thúc onboarding -> Home.
  void next() {
    if (page < lastIndex) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  /// Về trang trước; ở trang đầu thì thoát màn.
  void back() {
    if (page > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      Get.back();
    }
  }

  void skip() => _finish();

  void _finish() => Get.offAllNamed(AppPage.home.routeName);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
