import 'package:bank_taruna_mobile/core/network/api_client.dart';
import 'package:bank_taruna_mobile/features/news/news_article.dart';
import 'package:bank_taruna_mobile/shared/models/product_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';

import '../../shared/models/banner_item.dart';
import 'home_data.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const HomeRepository();
});

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  return ref.watch(homeRepositoryProvider).fetchHomeData();
});

class HomeRepository {
  const HomeRepository();

  Future<HomeData> fetchHomeData() async {
    final response = await ApiClient.createDio().get(ApiEndpoints.home);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data');
    }

    final body = _asStringDynamicMap(response.data);
    final data = _asStringDynamicMap(body['data']);

    debugPrint('Home data response Banner: ${data['banners']}');
    final banners = _apiList(data['banners']).map((raw) {
      final item = _asStringDynamicMap(raw);
      return BannerItem(
        title: item['name']?.toString() ?? '',
        subtitle: '',
        cta: 'Selengkapnya',
        imageUrl:
            '${AppConstants.baseUrl}recfil?display=true&rf=${item['url']}',
      );
    }).toList();

    debugPrint('Home data response Product: ${data['product']}');
    final products = _apiList(data['product']).asMap().entries.map((entry) {
      return _homeProductFromJson(
        _asStringDynamicMap(entry.value),
        entry.key,
      );
    }).where((product) {
      return product.title.trim().isNotEmpty;
    }).toList();

    debugPrint('Home data response News: ${data['news']}');
    final news = _apiList(data['news']).map((raw) {
      final item = _asStringDynamicMap(raw);
      return NewsArticle(
          content: item['content'] ?? '',
          date: DateTime.tryParse(item['created_at']?.toString() ?? '') ??
              DateTime.now(),
          excerpt: 'excerpt',
          id: item['id'],
          link: '',
          title: item['title']?.toString() ?? '',
          imageUrl:
              '${AppConstants.baseUrl}recfil?display=true&rf=${item['thumbnail']}',
          bannerUrl:
              '${AppConstants.baseUrl}recfil?display=true&rf=${item['banner']}',
          category: item['category']?.toString() ?? '');
    }).toList();

    return HomeData(
      banners: banners,
      products: bankProducts(),
      latestNews: news,
    );
  }

  Future<ProductItem> fetchProductDetailById(String productId) async {
    final uri = await ApiClient.createDio()
        .get('${AppConstants.baseUrl}${ApiEndpoints.detailproduk}/$productId');

    if (uri.statusCode != 200) {
      throw Exception('Gagal memuat detail produk');
    }

    final jsonBody = uri.data;
    final data = jsonBody['data'];

    debugPrint('Product detail response: $data');

    // return ProductItem.fromJson(data);
    return ProductItem(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: Icons.account_balance_wallet_rounded,
      routeLabel: 'Info',
      colors: data['colors'],
    );
  }
}

List<dynamic> _apiList(dynamic value) {
  return value is List ? value : <dynamic>[];
}

Map<String, dynamic> _asStringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  return <String, dynamic>{};
}

ProductItem _homeProductFromJson(Map<String, dynamic> json, int index) {
  final title = _apiString(
    json,
    ['title', 'nama_produk', 'namaProduk', 'name', 'nama', 'judul'],
    fallback: '',
  );
  final typeName = _apiString(
    json,
    [
      'jenis',
      'jenis_produk',
      'jenisProduk',
      'kategori',
      'nama_kategori',
      'namaKategori',
      'category',
      'category_name',
      'categoryName',
      'type',
      'product_type',
      'productType',
    ],
    fallback: title,
  );
  final typeId = _apiString(
    json,
    [
      'type_id',
      'typeId',
      'jenis_id',
      'jenisId',
      'id_jenis',
      'idJenis',
      'category_id',
      'categoryId',
      'kategori_id',
      'kategoriId',
      'product_type_id',
      'productTypeId',
      'group_id',
      'groupId',
      'id',
    ],
    fallback: '',
  );
  final imageUrl = _homeProductImageUrl(json);
  final raw = <String, dynamic>{
    ...json,
    'type': typeName,
    'typeId': typeId,
    'thumbnail': imageUrl,
    'banner': imageUrl,
  };

  return ProductItem(
    title: title,
    description: _apiString(
      json,
      [
        'description',
        'deskripsi',
        'keterangan',
        'summary',
        'excerpt',
        'short_description',
        'shortDescription',
      ],
      fallback: 'Pilih untuk melihat daftar produk.',
    ),
    icon: _iconForHomeProduct(typeName.isEmpty ? title : typeName),
    routeLabel: 'Info',
    colors: '#ffffff',
    content: _apiString(json, ['content', 'konten', 'body'], fallback: ''),
    images: imageUrl,
    raw: raw,
  );
}

String _apiString(
  Map<String, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final parsed = _apiValueToString(json[key]);
    if (parsed != null && parsed.trim().isNotEmpty) return parsed.trim();
  }

  return fallback;
}

String? _apiValueToString(dynamic value) {
  if (value == null) return null;

  if (value is List) {
    for (final item in value) {
      final parsed = _apiValueToString(item);
      if (parsed != null && parsed.trim().isNotEmpty) return parsed.trim();
    }

    return null;
  }

  if (value is Map) {
    final json = _asStringDynamicMap(value);
    for (final key in [
      'url',
      'path',
      'file',
      'filename',
      'thumbnail',
      'url_thumbnail',
      'banner',
      'url_banner',
      'image',
      'image_url',
      'name',
      'nama',
      'title',
      'label',
    ]) {
      final parsed = _apiValueToString(json[key]);
      if (parsed != null && parsed.trim().isNotEmpty) return parsed.trim();
    }

    return null;
  }

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

String? _homeProductImageUrl(Map<String, dynamic> json) {
  final rawImage = _apiValueToString(json['thumbnail']) ??
      _apiValueToString(json['url_thumbnail']) ??
      _apiValueToString(json['banner']) ??
      _apiValueToString(json['url_banner']) ??
      _apiValueToString(json['image']) ??
      _apiValueToString(json['gambar']) ??
      _apiValueToString(json['images']);

  return _homeImageUrl(rawImage);
}

String? _homeImageUrl(dynamic raw) {
  final value = _apiValueToString(raw);
  if (value == null || value.trim().isEmpty) return null;

  final imagePath = value.trim();
  final cleanBaseUrl = AppConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');

  String recfileUrl(String path) {
    final cleanPath = path.replaceAll(RegExp(r'^/+'), '');
    return '$cleanBaseUrl/recfil?display=true&rf=${Uri.encodeComponent(cleanPath)}';
  }

  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    final storageMarker = RegExp(r'/storage/+');
    if (storageMarker.hasMatch(imagePath)) {
      return recfileUrl(imagePath.split(storageMarker).last);
    }

    return imagePath;
  }

  if (imagePath.startsWith('recfil?')) return '$cleanBaseUrl/$imagePath';
  if (imagePath.startsWith('storage/')) {
    return recfileUrl(imagePath.replaceFirst(RegExp(r'^storage/+'), ''));
  }
  if (!imagePath.contains('/')) return recfileUrl(imagePath);

  return '$cleanBaseUrl/${imagePath.replaceAll(RegExp(r'^/+'), '')}';
}

IconData _iconForHomeProduct(String value) {
  final normalized = value.toLowerCase();

  if (normalized.contains('kredit') || normalized.contains('pinjaman')) {
    return Icons.payments_rounded;
  }
  if (normalized.contains('deposito') || normalized.contains('deposit')) {
    return Icons.savings_rounded;
  }
  if (normalized.contains('tabungan') || normalized.contains('saving')) {
    return Icons.account_balance_wallet_rounded;
  }

  return Icons.account_balance_rounded;
}
