import 'package:flutter/material.dart';

import '../../shared/models/banner_item.dart';
import '../../shared/models/product_item.dart';
import '../news/news_article.dart';

class HomeData {
  const HomeData({
    required this.banners,
    required this.products,
    required this.latestNews,
  });

  final List<BannerItem> banners;
  final List<ProductItem> products;
  final List<NewsArticle> latestNews;
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
