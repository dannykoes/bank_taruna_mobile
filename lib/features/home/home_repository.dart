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
    debugPrint('Home data response Body: $body');

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

    final profileMap = _apiMap(body, [
      'profile',
      'profil',
      'company_profile',
      'companyProfile',
      'tentang_kami',
      'tentangKami',
    ]);
    final visionMissionMap = _firstApiMap([
      _apiMap(body, [
        'vision_mission',
        'visionMission',
        'visi_misi',
        'visiMisi',
        'visimisi',
      ]),
      _apiMap(data, [
        'vision_mission',
        'visionMission',
        'visi_misi',
        'visiMisi',
        'visimisi',
      ]),
    ]);
    final contact = _firstApiMap([
      _apiMap(profileMap, [
        'contact',
        'kontak',
        'hubungi_kami',
        'hubungiKami',
      ]),
      _apiMap(body, [
        'contact',
        'kontak',
        'hubungi_kami',
        'hubungiKami',
      ]),
      _apiMap(data, [
        'contact',
        'kontak',
        'hubungi_kami',
        'hubungiKami',
      ]),
    ]);
    final transaction = _apiMap(data, [
      'transaction',
      'transactions',
      'transaksi',
      'transaction_screen',
      'transactionScreen',
    ]);
    final profileMaps = [visionMissionMap, profileMap, body, data];
    final contactMaps = [contact, body, profileMap, data];
    final missionTexts = _apiTextList(_apiValueFromMaps(profileMaps, [
      'missions',
      'mission',
      'misi',
      'mission_text',
      'missionText',
      'misi_text',
      'misiText',
    ]));
    final starsValues = _apiStarsValues(_apiValueFromMaps(profileMaps, [
      'stars',
      'nilai_layanan',
      'nilaiLayanan',
      'service_values',
      'serviceValues',
      'values',
      'nilai',
    ]));
    final contactWhatsapp = _normalizeWhatsapp(_apiStringFromMaps(
        contactMaps,
        [
          'whatsapp',
          'whatsapp_display',
          'whats_app',
          'whatsApp',
          'whatsappDisplay',
          'wa',
          'wa_display',
          'no_wa',
          'noWa',
        ],
        fallback: AppConstants.whatsapp));

    return HomeData(
      banners: banners,
      products: bankProducts(),
      latestNews: news,
      profileText: _apiStringFromMaps([
        body,
        profileMap,
        data
      ], [
        'profile',
        'profil',
        'company_profile',
        'companyProfile',
        'tentang_kami',
        'tentangKami',
        'description',
        'deskripsi',
        'content',
        'konten',
        'text',
      ], fallback: HomeData.defaultProfileText),
      visionMissionText: _apiStringFromMaps([
        body,
        visionMissionMap,
        profileMap,
        data
      ], [
        'vision_mission',
        'visionMission',
        'visi_misi',
        'visiMisi',
        'visimisi',
        'description',
        'deskripsi',
        'content',
        'konten',
        'text',
      ], fallback: HomeData.defaultVisionMissionText),
      transactionImageUrl: _homeImageUrl(_apiValueFromMaps([
        transaction,
        data,
      ], [
        'transaction_image',
        'transactionImage',
        'transaction_banner',
        'transactionBanner',
        'transaksi_image',
        'transaksiImage',
        'transaksi_banner',
        'transaksiBanner',
        'mobile_transaction_image',
        'mobileTransactionImage',
        'image',
        'gambar',
        'banner',
        'thumbnail',
      ])),
      visionText: _apiStringFromMaps(
          profileMaps,
          [
            'vision',
            'visi',
            'vision_text',
            'visionText',
            'visi_text',
            'visiText',
          ],
          fallback: HomeData.defaultVisionText),
      missionTexts:
          missionTexts.isEmpty ? HomeData.defaultMissionTexts : missionTexts,
      starsValues:
          starsValues.isEmpty ? HomeData.defaultStarsValues : starsValues,
      contactPhone: _apiStringFromMaps(
          contactMaps,
          [
            'phone',
            'telepon',
            'telephone',
            'telp',
            'no_telp',
            'noTelp',
          ],
          fallback: AppConstants.phone),
      contactWhatsapp: contactWhatsapp,
      contactWhatsappDisplay: _apiStringFromMaps(
          contactMaps,
          [
            'whatsapp_display',
            'whatsappDisplay',
            'wa_display',
            'waDisplay',
            'whatsapp',
            'wa',
          ],
          fallback: contactWhatsapp.isEmpty
              ? AppConstants.whatsappDisplay
              : contactWhatsapp),
      contactEmail: _apiStringFromMaps(
          contactMaps,
          [
            'email',
            'mail',
            'e_mail',
            'eMail',
          ],
          fallback: AppConstants.email),
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

Map<String, dynamic> _apiMap(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map) return _asStringDynamicMap(value);
  }

  return <String, dynamic>{};
}

Map<String, dynamic> _firstApiMap(List<Map<String, dynamic>> maps) {
  for (final map in maps) {
    if (map.isNotEmpty) return map;
  }

  return <String, dynamic>{};
}

dynamic _apiValueFromMaps(
  List<Map<String, dynamic>> maps,
  List<String> keys,
) {
  for (final map in maps) {
    for (final key in keys) {
      final value = map[key];
      if (value is Map && value.isNotEmpty) return value;
      if (value is List && value.isNotEmpty) return value;
      final parsed = _apiValueToString(value);
      if (parsed != null && parsed.trim().isNotEmpty) return value;
    }
  }

  return null;
}

String _apiStringFromMaps(
  List<Map<String, dynamic>> maps,
  List<String> keys, {
  required String fallback,
}) {
  final value = _apiValueFromMaps(maps, keys);
  final parsed = _apiValueToString(value);
  return parsed == null || parsed.trim().isEmpty ? fallback : parsed.trim();
}

List<String> _apiTextList(dynamic value) {
  if (value == null) return const <String>[];

  if (value is List) {
    return value
        .expand(_apiTextList)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  if (value is Map) {
    final json = _asStringDynamicMap(value);
    final nested = _apiTextList(json['items'] ?? json['data'] ?? json['list']);
    if (nested.isNotEmpty) return nested;

    final text = _apiValueToString(json['text'] ??
        json['content'] ??
        json['description'] ??
        json['value'] ??
        json['name'] ??
        json['title']);
    if (text != null) return _splitApiText(text);

    return json.values
        .expand(_apiTextList)
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  final text = _apiValueToString(value);
  return text == null ? const <String>[] : _splitApiText(text);
}

List<String> _splitApiText(String text) {
  final separator =
      text.contains('\n') ? RegExp(r'\r?\n+') : RegExp(r'\s*\|\s*');
  return text
      .split(separator)
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<HomeStarsValue> _apiStarsValues(dynamic value) {
  if (value == null) return const <HomeStarsValue>[];

  if (value is List) {
    return value.asMap().entries.expand((entry) {
      return _apiStarsValue(entry.value, entry.key);
    }).toList();
  }

  if (value is Map) {
    final json = _asStringDynamicMap(value);
    final nested = json['items'] ?? json['data'] ?? json['list'];
    if (nested != null) return _apiStarsValues(nested);

    return json.entries.map((entry) {
      final description = _apiValueToString(entry.value)?.trim() ?? '';
      return HomeStarsValue(
        title: _humanizeKey(entry.key),
        description: description,
        icon: _starsIconFor(entry.key, json.keys.toList().indexOf(entry.key)),
      );
    }).where((item) {
      return item.title.trim().isNotEmpty || item.description.trim().isNotEmpty;
    }).toList();
  }

  final text = _apiValueToString(value);
  if (text == null || text.trim().isEmpty) return const <HomeStarsValue>[];

  return [
    HomeStarsValue(
      title: 'STARS',
      description: text.trim(),
      icon: Icons.stars_rounded,
    ),
  ];
}

List<HomeStarsValue> _apiStarsValue(dynamic value, int index) {
  if (value is Map) {
    final json = _asStringDynamicMap(value);
    final title = _apiString(
        json,
        [
          'title',
          'name',
          'label',
          'key',
          'kode',
          'nilai',
        ],
        fallback: _defaultStarsTitle(index));
    final description = _apiString(
        json,
        [
          'description',
          'desc',
          'text',
          'content',
          'value',
          'keterangan',
        ],
        fallback: '');

    return [
      HomeStarsValue(
        title: title,
        description: description,
        icon: _starsIconFor(title, index),
      ),
    ];
  }

  final text = _apiValueToString(value);
  if (text == null || text.trim().isEmpty) return const <HomeStarsValue>[];

  return [
    HomeStarsValue(
      title: _defaultStarsTitle(index),
      description: text.trim(),
      icon: _starsIconFor(text, index),
    ),
  ];
}

String _defaultStarsTitle(int index) {
  if (index >= 0 && index < HomeData.defaultStarsValues.length) {
    return HomeData.defaultStarsValues[index].title;
  }

  return 'STARS';
}

IconData _starsIconFor(String value, int index) {
  final normalized = value.toLowerCase();
  if (normalized.contains('service')) return Icons.support_agent_rounded;
  if (normalized.contains('target')) return Icons.track_changes_rounded;
  if (normalized.contains('account')) return Icons.verified_rounded;
  if (normalized.contains('reliable')) return Icons.handshake_rounded;
  if (normalized.contains('synergy')) return Icons.groups_rounded;
  if (index >= 0 && index < HomeData.defaultStarsValues.length) {
    return HomeData.defaultStarsValues[index].icon;
  }

  return Icons.stars_rounded;
}

String _humanizeKey(String key) {
  final words = key
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
        return '${match.group(1)} ${match.group(2)}';
      })
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}');
  return words.join(' ');
}

String _normalizeWhatsapp(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) return '0${digits.substring(2)}';
  return digits.isEmpty ? value : digits;
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
