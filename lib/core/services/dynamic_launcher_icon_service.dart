import 'package:flutter/services.dart';

/// Service kecil untuk mengganti launcher icon Android.
/// Icon yang bisa dipilih harus sudah didaftarkan sebagai activity-alias di AndroidManifest.xml.
class DynamicLauncherIconService {
  static const MethodChannel _channel = MethodChannel('bank_taruna_mobile/app_icon');

  static const String defaultIcon = 'default';
  static const String kemerdekaan = 'kemerdekaan';
  static const String ramadan = 'ramadan';
  static const String idulFitri = 'idul_fitri';
  static const String natal = 'natal';
  static const String pahlawan = 'pahlawan';

  static Future<void> setIcon(String icon) async {
    await _channel.invokeMethod<void>('setIcon', {'icon': icon});
  }
}
