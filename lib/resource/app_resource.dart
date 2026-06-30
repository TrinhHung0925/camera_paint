const assetsImgPath = 'assets/images';
const assetsIconPath = 'assets/icons';

/// Quản lý tập trung đường dẫn tĩnh cho ảnh và icon (tránh gõ sai chính tả).
///
/// - `assets/images`: ảnh (Image/Banner).
/// - `assets/icons`: icon (export PNG scale 4 từ Figma).
///
/// Sử dụng: `Image.asset(Img.icXxx, width: N.h, height: N.h)`.
abstract class Img {
  /// icons
  // static const String icMenuDiscoverSelect = '$assetsIconPath/ic_menu_discover_select.png';

  /// images
  static const String imgOnboardingTokyo = '$assetsImgPath/img_onboarding_tokyo.jpg';
  static const String imgDestTokyo = '$assetsImgPath/img_dest_tokyo.jpg';
  static const String imgDestBali = '$assetsImgPath/img_dest_bali.jpg';
  static const String imgDestParis = '$assetsImgPath/img_dest_paris.jpg';
  static const String imgDestNewyork = '$assetsImgPath/img_dest_newyork.jpg';
  static const String imgDestIceland = '$assetsImgPath/img_dest_iceland.jpg';
  static const String imgDestKyoto = '$assetsImgPath/img_dest_kyoto.jpg';
  static const String imgFood = '$assetsImgPath/img_food.jpg';
  static const String imgTokyoTower = '$assetsImgPath/img_tokyo_tower.jpg';
  static const String imgFuji = '$assetsImgPath/img_fuji.jpg';
}
