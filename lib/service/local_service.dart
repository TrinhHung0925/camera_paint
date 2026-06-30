import 'package:get_storage/get_storage.dart';

/// Khai báo các key lưu trữ local (tránh hardcode string), truy cập qua `LocalKey.xyz.name`.
enum LocalKey {
  intro,
}

/// Global service quản lý lưu trữ local key-value qua `get_storage`.
///
/// Lưu ý: phải gọi `await GetStorage.init();` trong `main()` trước khi dùng.
class LocalService {
  static final LocalService shared = LocalService._internal();

  factory LocalService() => shared;

  LocalService._internal();

  var storage = GetStorage();

  void saveIntro() {
    storage.write(LocalKey.intro.name, false);
  }

  bool getIntro() {
    return storage.read(LocalKey.intro.name) ?? true;
  }
}
