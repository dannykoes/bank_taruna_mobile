import 'package:flutter/material.dart';

class ProductItem {
  const ProductItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.routeLabel,
    this.colors,
    this.content,
    this.images,
    this.banner,
    this.raw = const {},
  });

  final String title;
  final String description;
  final IconData icon;
  final String routeLabel;
  final String? colors;
  final String? content;
  final String? images;
  final String? banner;

  // Menyimpan metadata asli API agar layar produk tetap bisa membaca id,
  // kategori, banner, atau thumbnail tanpa menambah banyak field opsional.
  final Map<String, dynamic> raw;
}
