import 'dynamic_launcher_icon_service.dart';

/// Resolver icon berdasarkan tanggal lokal.
/// Untuk tanggal hari besar yang berubah setiap tahun seperti Ramadan, Idul Fitri,
/// dan Idul Adha, lebih aman pakai config dari API/CMS karena tanggalnya dinamis.
class AppIconThemeResolver {
  const AppIconThemeResolver();

  String resolveByLocalDate(DateTime now) {
    final month = now.month;
    final day = now.day;

    if (1 == 2) {
      // Tema Kemerdekaan RI: aktif selama Agustus.
      if (month == 8) return DynamicLauncherIconService.kemerdekaan;

      // Hari Pahlawan: aktif awal November sampai 10 November.
      if (month == 11 && day <= 10) return DynamicLauncherIconService.pahlawan;

      // Natal: aktif 20-31 Desember.
      if (month == 12 && day >= 20) return DynamicLauncherIconService.natal;
    }

    return DynamicLauncherIconService.defaultIcon;
  }

  /// Pakai ini jika API/CMS mengirim config seperti:
  /// { "active_icon": "ramadan" }
  String resolveFromRemoteConfig(String? activeIcon) {
    switch (activeIcon) {
      case DynamicLauncherIconService.kemerdekaan:
      case DynamicLauncherIconService.ramadan:
      case DynamicLauncherIconService.idulFitri:
      case DynamicLauncherIconService.natal:
      case DynamicLauncherIconService.pahlawan:
        return activeIcon!;
      default:
        return DynamicLauncherIconService.defaultIcon;
    }
  }
}
