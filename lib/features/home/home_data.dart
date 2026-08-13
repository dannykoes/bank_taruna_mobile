import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../shared/models/banner_item.dart';
import '../../shared/models/product_item.dart';
import '../news/news_article.dart';

class HomeData {
  const HomeData({
    required this.banners,
    required this.products,
    required this.latestNews,
    this.transactionImageUrl,
    this.profileText = defaultProfileText,
    this.visionMissionText = defaultVisionMissionText,
    this.visionText = defaultVisionText,
    this.missionTexts = defaultMissionTexts,
    this.starsValues = defaultStarsValues,
    this.contactPhone = AppConstants.phone,
    this.contactWhatsapp = AppConstants.whatsapp,
    this.contactWhatsappDisplay = AppConstants.whatsappDisplay,
    this.contactEmail = AppConstants.email,
  });

  static const defaultVisionText =
      'Menjadi BPR yang Bersih, Sehat, dan Terpercaya.';
  static const defaultProfileText = AppConstants.ojkLpsNote;
  static const defaultVisionMissionText = '';
  static const defaultMissionTexts = [
    'Memberikan pelayanan terbaik kepada nasabah serta berperan aktif membantu pemerintah dalam pengembangan UMKM.',
    'Meningkatkan kinerja BPR yang sehat, kuat, efisien, profesional, dan berkesinambungan.',
    'Memberikan pengetahuan tentang manajemen keuangan kepada nasabah.',
    'Menjadikan pemasaran sebagai konsultan keuangan dan produk bagi nasabah.',
  ];
  static const defaultStarsValues = [
    HomeStarsValue(
      title: 'Service Excellence',
      description: 'Pelayanan prima kepada nasabah.',
      icon: Icons.support_agent_rounded,
    ),
    HomeStarsValue(
      title: 'Target Oriented',
      description: 'Orientasi pada pencapaian target.',
      icon: Icons.track_changes_rounded,
    ),
    HomeStarsValue(
      title: 'Accountability',
      description: 'Bertanggung jawab sesuai ketentuan.',
      icon: Icons.verified_rounded,
    ),
    HomeStarsValue(
      title: 'Reliable',
      description: 'Dapat diandalkan untuk menyelesaikan pekerjaan.',
      icon: Icons.handshake_rounded,
    ),
    HomeStarsValue(
      title: 'Synergy',
      description: 'Membangun kerja sama yang baik.',
      icon: Icons.groups_rounded,
    ),
  ];

  final List<BannerItem> banners;
  final List<ProductItem> products;
  final List<NewsArticle> latestNews;
  final String? transactionImageUrl;
  final String profileText;
  final String visionMissionText;
  final String visionText;
  final List<String> missionTexts;
  final List<HomeStarsValue> starsValues;
  final String contactPhone;
  final String contactWhatsapp;
  final String contactWhatsappDisplay;
  final String contactEmail;
}

class HomeStarsValue {
  const HomeStarsValue({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

List<ProductItem> bankProducts() {
  return const [
    ProductItem(
      title: 'Kredit',
      description:
          'Ajukan kebutuhan pembiayaan dengan proses yang mudah dan terarah.',
      icon: Icons.account_balance_wallet_rounded,
      routeLabel: 'Simulasi',
      colors: '#ffffff',
    ),
    ProductItem(
      title: 'Deposito',
      description:
          'Simpan dana berjangka dengan pilihan tenor sesuai kebutuhan.',
      icon: Icons.savings_rounded,
      routeLabel: 'Info',
      colors: '#ffffff',
    ),
    ProductItem(
      title: 'Tabungan',
      description:
          'Produk tabungan untuk kebutuhan harian, mikro, pelajar, dan prima.',
      icon: Icons.credit_card_rounded,
      routeLabel: 'Ajukan',
      colors: '#ffffff',
    ),
  ];
}
