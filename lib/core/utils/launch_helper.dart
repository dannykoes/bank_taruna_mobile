import 'package:url_launcher/url_launcher.dart';

class LaunchHelper {
  const LaunchHelper._();

  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak dapat membuka $url');
    }
  }

  static Future<void> whatsapp(String phone, {String? text}) async {
    final encoded = Uri.encodeComponent(text ?? 'Halo Bank Taruna, saya ingin bertanya.');
    await openUrl('https://wa.me/62${phone.replaceFirst(RegExp(r'^0'), '')}?text=$encoded');
  }

  static Future<void> phone(String phone) => openUrl('tel:$phone');

  static Future<void> email(String email) => openUrl('mailto:$email');
}
