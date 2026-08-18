import 'package:bank_taruna_mobile/core/constants/api_endpoints.dart';
import 'package:bank_taruna_mobile/core/network/api_client.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/date_formatter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/launch_helper.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';
import '../../shared/models/banner_item.dart';
import '../../shared/models/product_item.dart';
import '../applications/loan_application_screen.dart';
import '../news/news_article.dart';
import '../news/news_detail_screen.dart';
import '../news/news_screen.dart';
import 'home_data.dart';
import 'home_repository.dart';

// Provider untuk mengambil detail satu produk berdasarkan ID produk.
// Dipanggil saat user menekan kartu sub produk.
final productDetailProvider =
    FutureProvider.family<ProductItem, String>((ref, productId) async {
  return fetchSingleProductDetailById(productId);
});

// Provider untuk mengambil daftar sub produk berdasarkan ID jenis/kategori.
// Contoh: Kredit -> Kredit A, Kredit B, dan seterusnya.
final productTypeProductsProvider =
    FutureProvider.family<List<_ApiProductItem>, String>((ref, typeId) async {
  return fetchProductsByTypeId(typeId);
});

// Cache base URL asset agar tidak membuat Dio berulang kali saat banyak gambar dirender.
String? _cachedApiAssetBaseUrl;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);
    return RefreshIndicator(
      // onRefresh: () async => ref.invalidate(homeDataProvider),
      onRefresh: () async => ref.invalidate(homeDataProvider),
      child: homeData.when(
        data: (data) => _HomeContent(data: data, onNavigate: onNavigate),
        loading: () => const _HomeLoading(),
        error: (error, _) => ErrorState(
          message: 'Beranda belum dapat dimuat. ${error.toString()}',
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({required this.data, required this.onNavigate});

  final HomeData data;
  final ValueChanged<int> onNavigate;

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ResponsiveContainer(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandHeader(
                    subtitle: 'Informasi, simulasi, dan pengajuan online'),
                const SizedBox(height: 18),
                _BannerCarousel(
                  controller: _pageController,
                  banners: widget.data.banners,
                  onNavigate: widget.onNavigate,
                ),
                const SizedBox(height: 18),
                _ValuePlusCard(onNavigate: widget.onNavigate),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Yang bisa dilakukan',
                  subtitle: 'Pilih produk utama Bank Taruna.',
                ),
                const SizedBox(height: 12),
                _ProductGrid(
                    products: widget.data.products,
                    onNavigate: widget.onNavigate),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Informasi Terbaru',
                  subtitle: 'Berita dan literasi keuangan terbaru.',
                  actionLabel: 'Lihat Semua',
                  onAction: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: SafeArea(
                          child: NewsScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.data.latestNews.map((article) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _NewsPreviewCard(article: article),
                    )),
                const SizedBox(height: 20),
                _TrustNote(),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({
    required this.controller,
    required this.banners,
    required this.onNavigate,
  });

  final PageController controller;
  final List<BannerItem> banners;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final item = banners[index];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: item.imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(item.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: item.imageUrl == null
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.deepBlue,
                              AppColors.primaryRed,
                            ],
                          )
                        : null,
                  ),
                  // child: Stack(
                  //   children: [
                  //     Positioned(
                  //       right: -24,
                  //       bottom: -24,
                  //       child: Icon(
                  //         Icons.account_balance_rounded,
                  //         size: 142,
                  //         color: Colors.white.withOpacity(0.08),
                  //       ),
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 12, vertical: 7),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white.withOpacity(0.16),
                  //             borderRadius: BorderRadius.circular(999),
                  //           ),
                  //           child: const Text(
                  //             'BPR Taruna Adidaya Santosa',
                  //             style: TextStyle(
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.w700,
                  //                 fontSize: 12),
                  //           ),
                  //         ),
                  //         const SizedBox(height: 12),
                  //         Text(
                  //           item.title,
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: Theme.of(context)
                  //               .textTheme
                  //               .headlineSmall
                  //               ?.copyWith(
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.w900,
                  //                 height: 1.05,
                  //               ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Text(
                  //           item.subtitle,
                  //           maxLines: 2,
                  //           overflow: TextOverflow.ellipsis,
                  //           style: TextStyle(
                  //               color: Colors.white.withOpacity(0.88),
                  //               height: 1.35),
                  //         ),
                  //         // const SizedBox(height: 16),
                  //         // FilledButton.tonalIcon(
                  //         //   onPressed: () => onNavigate(index == 1
                  //         //       ? 1
                  //         //       : index == 2
                  //         //           ? 4
                  //         //           : 2),
                  //         //   icon: const Icon(Icons.arrow_forward_rounded),
                  //         //   label: Text(item.cta),
                  //         // ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: controller,
          count: banners.length,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.primaryBlue,
            dotColor: AppColors.border,
          ),
        ),
      ],
    );
  }
}

class _ValuePlusCard extends StatelessWidget {
  const _ValuePlusCard({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.skyBlue],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34,
                top: -42,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 18,
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 82,
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STARS dari Bank Taruna',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Nilai layanan yang menjadi budaya kerja Bank Taruna untuk memberi pelayanan terbaik bagi nasabah.',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ValueChip(
                          icon: Icons.support_agent_rounded,
                          label: 'Service Excellence',
                        ),
                        _ValueChip(
                          icon: Icons.track_changes_rounded,
                          label: 'Target Oriented',
                        ),
                        _ValueChip(
                          icon: Icons.verified_user_rounded,
                          label: 'Accountability',
                        ),
                        _ValueChip(
                          icon: Icons.handshake_rounded,
                          label: 'Reliable',
                        ),
                        _ValueChip(
                          icon: Icons.groups_rounded,
                          label: 'Synergy',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 360;
                        final primaryButton = FilledButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const Scaffold(
                                body: SafeArea(
                                  child: LoanApplicationScreen(),
                                ),
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.assignment_turned_in_rounded),
                          label: const Text('Ajukan Sekarang'),
                        );
                        final secondaryButton = OutlinedButton.icon(
                          onPressed: () => LaunchHelper.whatsapp(
                            AppConstants.whatsapp,
                          ),
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text('Chat CS'),
                        );

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              primaryButton,
                              const SizedBox(height: 10),
                              secondaryButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: primaryButton),
                            const SizedBox(width: 10),
                            Expanded(child: secondaryButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products, required this.onNavigate});

  final List<ProductItem> products;
  final ValueChanged<int> onNavigate;

  // section produk berdasarkan jenis produk dari API
  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const AppCard(
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.muted),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Produk belum tersedia. Tarik ke bawah untuk memuat ulang data.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final groups = _productGroupsFromApi(products);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 920
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: groups.map((group) {
            return SizedBox(
              width: cardWidth,
              child: _ProductTypeCard(
                group: group,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductTypeScreen(
                        typeId: group.id,
                        typeName: group.title,
                        bannerUrl: group.bannerUrl,
                        products: group.products,
                        onNavigate: onNavigate,
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ProductTypeCard extends StatelessWidget {
  const _ProductTypeCard({
    required this.group,
    required this.onTap,
  });

  final _ProductTypeGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconUrl =
        group.products.isEmpty ? null : _productIconUrlOf(group.products.first);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -22,
              child: Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 12,
              child: Icon(
                Icons.layers_rounded,
                size: 70,
                color: AppColors.primaryBlue.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'product-type-${group.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: iconUrl == null
                              ? Icon(group.icon, color: Colors.white)
                              : CachedNetworkImage(
                                  imageUrl: iconUrl,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Icon(
                                    group.icon,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 9,
                        //     vertical: 5,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: AppColors.skyBlue,
                        //     borderRadius: BorderRadius.circular(999),
                        //   ),
                        //   child: Text(
                        //     '${group.products.length} produk',
                        //     style: const TextStyle(
                        //       color: AppColors.primaryBlue,
                        //       fontSize: 11,
                        //       fontWeight: FontWeight.w900,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        Text(
                          group.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          group.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mengambil detail satu produk dari API berdasarkan ID.
///
/// API mengembalikan data dalam bentuk wrapper:
/// { success: true, message: "...", data: [ {...produk...} ] }
/// Karena detail hanya membutuhkan satu produk, kita ambil item pertama dari data.
Future<ProductItem> fetchSingleProductDetailById(String productId) async {
  final response = await ApiClient.createDio().get(
    '${ApiEndpoints.detailproduk}/alljenis',
    queryParameters: {'id': productId},
  );

  _throwIfInvalidStatus(response.statusCode, 'detail produk');

  final body = response.data;
  if (body is! Map) {
    throw Exception('Format response detail produk tidak valid.');
  }

  final jsonBody = _asStringDynamicMap(body);
  if (jsonBody['success'] == false) {
    throw Exception(
      jsonBody['message']?.toString() ?? 'Gagal memuat detail produk.',
    );
  }

  final rawItems = _extractApiProductList(jsonBody);
  if (rawItems.isEmpty) {
    throw Exception('Detail produk belum diisi.');
  }

  final detailJson = _asStringDynamicMap(rawItems.first);
  return _apiProductItemFromJson(
    detailJson,
    fallbackTypeName: 'Produk',
    fallbackIndex: 0,
  ).product;
}

/// Mengambil sub produk berdasarkan jenis/kategori yang dipilih.
///
/// Catatan penting:
/// - Jika API mengembalikan data kosong, fungsi ini return list kosong.
/// - UI akan menampilkan keterangan "data belum diisi" dan tidak lagi
///   fallback ke data dummy dari halaman beranda.
Future<List<_ApiProductItem>> fetchProductsByTypeId(String typeId) async {
  final response =
      await ApiClient.createDio().get('${ApiEndpoints.detailproduk}/$typeId');
  _throwIfInvalidStatus(response.statusCode, 'produk');

  final rawItems = _extractApiProductList(response.data);
  if (rawItems.isEmpty) return <_ApiProductItem>[];

  return rawItems.asMap().entries.map((entry) {
    final json = _asStringDynamicMap(entry.value);
    return _apiProductItemFromJson(
      json,
      fallbackTypeName: typeId,
      fallbackIndex: entry.key,
    );
  }).toList(growable: false);
}

/// Backward compatibility bila masih ada pemanggilan lama di file lain.
Future<List<_ApiProductItem>> fetchProductDetailById(String productId) {
  return fetchProductsByTypeId(productId);
}

/// Validasi status code response agar error API mudah dibaca di UI.
void _throwIfInvalidStatus(int? statusCode, String contextName) {
  final code = statusCode ?? 0;
  if (code < 200 || code >= 300) {
    throw Exception('Gagal memuat $contextName. Status code: $code');
  }
}

/// Mengubah berbagai kemungkinan bentuk response API menjadi list produk.
///
/// Mendukung bentuk:
/// - [ {...}, {...} ]
/// - { data: [ {...} ] }
/// - { data: { products: [ {...} ] } }
List<dynamic> _extractApiProductList(dynamic raw) {
  if (raw == null) return <dynamic>[];
  if (raw is List) return raw;

  if (raw is Map) {
    final json = _asStringDynamicMap(raw);

    for (final key in const [
      'data',
      'produk',
      'products',
      'items',
      'result',
      'results',
      'list',
    ]) {
      final value = json[key];

      // Jika API eksplisit mengembalikan list kosong, jangan fallback ke dummy.
      if (value is List) return value;

      if (value is Map) {
        final nested = _extractApiProductList(value);
        if (nested.isNotEmpty) return nested;
      }
    }

    // Single object produk tetap didukung untuk endpoint detail.
    if (_looksLikeProductObject(json)) return <dynamic>[json];
  }

  return <dynamic>[];
}

/// Mengecek apakah object map terlihat seperti object produk.
/// Ini mencegah wrapper API kosong seperti {success, message, data: []}
/// dianggap sebagai produk dummy.
bool _looksLikeProductObject(Map<String, dynamic> json) {
  const productKeys = [
    'id',
    'title',
    'nama',
    'nama_produk',
    'deskripsi',
    'description',
    'content',
    'thumbnail',
    'thumbail',
    'banner',
    'image',
    'slug',
  ];

  return productKeys.any(json.containsKey);
}

_ApiProductItem _apiProductItemFromJson(
  Map<String, dynamic> json, {
  required String fallbackTypeName,
  required int fallbackIndex,
}) {
  final typeName = _titleCase(
    _apiString(
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
      fallback: fallbackTypeName,
    ),
  );

  final title = _apiString(
    json,
    [
      'title',
      'nama_produk',
      'namaProduk',
      'name',
      'nama',
      'judul',
    ],
    fallback: 'Produk ${fallbackIndex + 1}',
  );

  final description = _apiString(
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
    fallback: 'Detail produk tersedia Website Bank Taruna.',
  );

  final productId = _apiString(
    json,
    [
      'id',
      'product_id',
      'productId',
      'produk_id',
      'produkId',
      'kode_produk',
      'kodeProduk',
      'code',
      'slug',
    ],
    fallback: '',
  );

  final safeProductId = productId.trim().isNotEmpty
      ? productId.trim()
      : '${productSafeSlug(title)}-${fallbackIndex + 1}';

  final imageUrl = _apiImageUrlFromJson(json);
  final bannerUrl = _apiBannerUrlFromJson(json);
  final content = _apiString(
    json,
    ['content', 'konten', 'body'],
    fallback: '',
  );

  return _ApiProductItem(
    productId: safeProductId,
    typeName: typeName.trim().isEmpty ? fallbackTypeName : typeName,
    images: imageUrl,
    content: content,
    product: ProductItem(
      title: title,
      description: description,
      icon: _iconForProductType(typeName),
      routeLabel: _apiString(
        json,
        ['routeLabel', 'route_label', 'cta', 'label'],
        fallback: 'Info',
      ),
      colors: _apiProductColor(typeName),
      content: content,
      images: imageUrl,
      banner: bannerUrl,
    ),
  );
}

Map<String, dynamic> _asStringDynamicMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), item),
    );
  }

  return <String, dynamic>{};
}

String _apiString(
  Map<String, dynamic> json,
  List<String> keys, {
  required String fallback,
}) {
  for (final key in keys) {
    final value = json[key];
    final parsed = _apiValueToString(value);
    if (parsed != null && parsed.trim().isNotEmpty) return parsed.trim();
  }

  return fallback;
}

String? _apiValueToString(dynamic value) {
  if (value == null) return null;

  if (value is Map) {
    final json = _asStringDynamicMap(value);
    for (final key in [
      'name',
      'nama',
      'title',
      'label',
      'jenis',
      'kategori',
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

/// Mengambil URL gambar dari response API.
/// Urutan prioritas: thumbnail -> thumbail -> banner -> image -> imageUrl.
String? _apiImageUrlFromJson(Map<String, dynamic> json) {
  final rawImage = _apiValueToString(json['thumbnail']) ??
      _apiValueToString(json['thumbail']) ??
      _apiValueToString(json['banner']) ??
      _apiValueToString(json['image']) ??
      _apiValueToString(json['imageUrl']) ??
      _apiValueToString(json['images']);

  return _fullApiImageUrl(rawImage);
}

String? _apiBannerUrlFromJson(Map<String, dynamic> json) {
  final rawImage = _apiValueToString(json['banner']) ??
      _apiValueToString(json['image']) ??
      _apiValueToString(json['imageUrl']) ??
      _apiValueToString(json['images']);

  return _fullApiImageUrl(rawImage);
}

/// Menjadikan path gambar dari API sebagai URL penuh.
///
/// Jika API mengirim "pages/banner/a.jpg", hasilnya menjadi:
/// baseUrl/pages/banner/a.jpg
/// Jika API sudah mengirim URL lengkap, nilai dikembalikan apa adanya.
String? _fullApiImageUrl(dynamic raw) {
  final value = _apiValueToString(raw);
  if (value == null || value.trim().isEmpty) return null;

  final imagePath = value.trim();

  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return imagePath;
  }

  final cleanBaseUrl = AppConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
  final cleanImagePath = imagePath.replaceAll(RegExp(r'^/+'), '');

  return '$cleanBaseUrl/recfil?display=true&rf=$cleanImagePath';
}

/// Base URL untuk asset gambar.
///
/// Beberapa project menyimpan baseUrl Dio dengan suffix `/api`.
/// Asset seperti banner/thumbnail biasanya berada di root domain, bukan di /api.
/// Jika project kamu memang menyajikan gambar dari /api, hapus replace /api ini.
String _apiAssetBaseUrl() {
  final cached = _cachedApiAssetBaseUrl;
  if (cached != null) return cached;

  final rawBaseUrl = ApiClient.createDio().options.baseUrl.trim();
  if (rawBaseUrl.isEmpty) {
    _cachedApiAssetBaseUrl = '';
    return '';
  }

  final cleanBaseUrl = rawBaseUrl.replaceAll(RegExp(r'/+$'), '');
  final assetBaseUrl = cleanBaseUrl.replaceFirst(RegExp(r'/api(/v\d+)?$'), '');

  _cachedApiAssetBaseUrl = assetBaseUrl;
  return assetBaseUrl;
}

String _apiProductColor(String typeName) {
  final value = typeName.toLowerCase();

  if (value.contains('kredit') ||
      value.contains('pinjaman') ||
      value.contains('loan')) {
    return '#0057B8';
  }

  if (value.contains('deposito') || value.contains('deposit')) {
    return '#C8102E';
  }

  if (value.contains('tabungan') || value.contains('saving')) {
    return '#0077B6';
  }

  return '#0F172A';
}

class _ApiProductItem {
  const _ApiProductItem({
    required this.productId,
    required this.product,
    required this.typeName,
    this.content,
    this.images,
  });

  final String productId;
  final ProductItem product;
  final String typeName;
  final String? images;
  final String? content;
}

class ProductTypeScreen extends ConsumerWidget {
  const ProductTypeScreen({
    super.key,
    required this.typeId,
    required this.typeName,
    this.bannerUrl,
    required this.products,
    required this.onNavigate,
  });

  final String typeId;
  final String typeName;
  final String? bannerUrl;

  // Data dari beranda tetap diterima untuk kebutuhan metadata kategori,
  // namun tidak dipakai sebagai fallback sub produk agar tidak muncul dummy.
  final List<ProductItem> products;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiProducts = ref.watch(productTypeProductsProvider(typeId));
    final totalProducts = apiProducts.maybeWhen(
      data: (items) => items.length,
      orElse: () => 0,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productTypeProductsProvider(typeId));
            try {
              await ref.read(productTypeProductsProvider(typeId).future);
            } catch (_) {
              // Error sudah ditampilkan melalui AsyncValue di section produk.
            }
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: ResponsiveContainer(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandHeader(
                        subtitle: 'Produk berdasarkan jenis layanan',
                      ),
                      const SizedBox(height: 12),
                      _BackLink(
                        label: 'Kembali ke Beranda',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 10),
                      _ProductTypeHero(
                        typeId: typeId,
                        typeName: typeName,
                        bannerUrl: bannerUrl,
                        totalProducts: totalProducts,
                      ),
                      const SizedBox(height: 20),
                      SectionHeader(
                        title: 'Sub Produk $typeName',
                        subtitle:
                            'Pilih salah satu produk untuk melihat detail.',
                      ),
                      const SizedBox(height: 12),
                      _ProductTypeProductsSection(
                        productsAsync: apiProducts,
                        typeName: typeName,
                        onNavigate: onNavigate,
                        onRetry: () {
                          ref.invalidate(productTypeProductsProvider(typeId));
                        },
                      ),
                      const SizedBox(height: 18),
                      _TrustNote(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTypeProductsSection extends StatelessWidget {
  const _ProductTypeProductsSection({
    required this.productsAsync,
    required this.typeName,
    required this.onNavigate,
    required this.onRetry,
  });

  final AsyncValue<List<_ApiProductItem>> productsAsync;
  final String typeName;
  final ValueChanged<int> onNavigate;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return productsAsync.when(
      loading: () => const _ProductTypeLoadingList(),
      error: (error, _) => _ProductTypeErrorState(
        typeName: typeName,
        error: error,
        onRetry: onRetry,
      ),
      data: (apiProducts) {
        if (apiProducts.isEmpty) {
          return _EmptyProductTypeState(typeName: typeName);
        }

        return _ProductTypeProductWrap(
          items: apiProducts,
          typeName: typeName,
          onNavigate: onNavigate,
          content: apiProducts.isNotEmpty ? apiProducts.first.content : null,
        );
      },
    );
  }
}

/// Tampilan saat API sukses tetapi data sub produk kosong.
/// Ini menggantikan fallback dummy agar user tahu data belum diisi dari CMS/API.
class _EmptyProductTypeState extends StatelessWidget {
  const _EmptyProductTypeState({required this.typeName});

  final String typeName;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.skyBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data produk $typeName belum diisi',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Belum ada sub produk dari API untuk jenis ini. Silakan isi data produk di CMS/API terlebih dahulu.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampilan error API tanpa fallback dummy.
class _ProductTypeErrorState extends StatelessWidget {
  const _ProductTypeErrorState({
    required this.typeName,
    required this.error,
    required this.onRetry,
  });

  final String typeName;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.primaryRed),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Gagal memuat produk $typeName dari API. $error',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _ProductTypeLoadingList extends StatelessWidget {
  const _ProductTypeLoadingList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12),
          child: AppCard(
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.skyBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memuat produk dari API...',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Mohon tunggu sebentar.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductTypeProductWrap extends StatelessWidget {
  const _ProductTypeProductWrap(
      {required this.items,
      required this.typeName,
      required this.onNavigate,
      this.content});

  final List<_ApiProductItem> items;
  final String typeName;
  final String? content;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 920
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;
              final product = item.product;
              final productId = item.productId.trim().isNotEmpty
                  ? item.productId.trim()
                  : _productIdOf(product, index);
              final cardTypeName = item.typeName.trim().isNotEmpty
                  ? item.typeName.trim()
                  : typeName;

              return SizedBox(
                width: cardWidth,
                child: _ProductCard(
                  product: product,
                  productId: productId,
                  typeName: cardTypeName,
                  images: item.images,
                  content: item.content ?? content,
                  onProductLoaded: (detailProduct) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: productId,
                          productType: cardTypeName,
                          product: detailProduct,
                          onNavigate: onNavigate,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }
}

class _ProductTypeHero extends StatelessWidget {
  const _ProductTypeHero({
    required this.typeId,
    required this.typeName,
    required this.bannerUrl,
    required this.totalProducts,
  });

  final String typeId;
  final String typeName;
  final String? bannerUrl;
  final int totalProducts;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForProductType(typeName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          image: bannerUrl == null
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(bannerUrl!),
                  fit: BoxFit.cover,
                  onError: (_, __) {},
                ),
          gradient: bannerUrl == null
              ? const LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.deepBlue,
                    AppColors.primaryRed,
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepBlue.withOpacity(0.22),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (bannerUrl != null)
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0)),
              ),
            // Positioned(
            //   right: -38,
            //   bottom: -44,
            //   child: Icon(
            //     Icons.account_balance_rounded,
            //     size: 155,
            //     color: Colors.white.withValues(alpha: 0),
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product-type-$typeId',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0),
                            ),
                          ),
                          child: Icon(icon,
                              color: Colors.white.withValues(alpha: 0),
                              size: 32),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 8,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.16),
                    //     borderRadius: BorderRadius.circular(999),
                    //   ),
                    //   child: Text(
                    //     '$totalProducts produk',
                    //     style: const TextStyle(
                    //       color: Colors.white,
                    //       fontSize: 11,
                    //       fontWeight: FontWeight.w900,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  typeName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0),
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                ),
                // const SizedBox(height: 8),
                // Text(
                //   'Semua produk $typeName.',
                //   style: TextStyle(
                //     color: Colors.white.withOpacity(0.88),
                //     height: 1.35,
                //     fontWeight: FontWeight.w600,
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerStatefulWidget {
  const _ProductCard({
    required this.product,
    required this.productId,
    required this.typeName,
    required this.onProductLoaded,
    this.content,
    this.images,
  });

  final ProductItem product;
  final String productId;
  final String typeName;
  final ValueChanged<ProductItem> onProductLoaded;
  final String? content;
  final String? images;

  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final detailProduct = await ref.read(
        productDetailProvider(widget.productId).future,
      );

      if (!mounted) return;

      widget.onProductLoaded(detailProduct);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail produk. $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// Kartu sub produk. Gambar diambil dari response API.
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.images ?? _productImageUrlOf(widget.product);

    return AppCard(
      onTap: _isLoading ? null : _handleTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -22,
              top: -22,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Opacity(
                opacity: _isLoading ? 0.72 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'product-icon-${widget.productId}',
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue
                                        .withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: imageUrl == null
                                    ? Icon(
                                        widget.product.icon,
                                        color: Colors.white,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (_, __, ___) => Icon(
                                            widget.product.icon,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(9),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.product.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productType,
    required this.product,
    this.onNavigate,
  });

  final String productId;
  final String productType;
  final ProductItem product;
  final ValueChanged<int>? onNavigate;

  @override
  Widget build(BuildContext context) {
    // Detail produk memakai gambar dari API: thumbnail/banner/image jika tersedia.
    final imageUrl = _productImageUrlOf(product);
    final bannerUrl = _productBannerUrlOf(product);

    debugPrint('product detail screen $bannerUrl');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ResponsiveContainer(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandHeader(subtitle: 'Detail produk dan layanan'),
                    const SizedBox(height: 12),
                    _BackLink(
                      label: 'Kembali ke daftar produk',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 10),
                    _ProductDetailHero(
                        product: product,
                        productId: productId,
                        productType: productType,
                        imageUrl: imageUrl,
                        bannerUrl: bannerUrl),
                    const SizedBox(height: 18),
                    SectionHeader(
                      title: product.title,
                      subtitle: product.description,
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          // _DetailInfoRow(
                          //   icon: Icons.qr_code_2_rounded,
                          //   title: 'ID Produk',
                          //   description: productId,
                          // ),
                          // const Divider(height: 24),
                          // _DetailInfoRow(
                          //   icon: Icons.category_rounded,
                          //   title: 'Jenis Produk',
                          //   description: productType,
                          // ),
                          // const Divider(height: 24),
                          // _DetailInfoRow(
                          //   icon: Icons.description_rounded,
                          //   title: 'Deskripsi',
                          //   description: product.description,
                          // ),
                          // const Divider(height: 24),
                          // const _DetailInfoRow(
                          //   icon: Icons.cloud_sync_rounded,
                          //   title: 'Sumber Data',
                          //   description:
                          //       'Produk berasal dari API, dikelompokkan berdasarkan jenis, lalu diteruskan ke detail menggunakan ID unik.',
                          // ),

                          if ((product.content ?? '').trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                ),
                              ),
                              child: Html(
                                data: product.content!,
                                style: {
                                  'body': Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    color: Colors.black.withOpacity(0.92),
                                    fontSize: FontSize(14),
                                    lineHeight: const LineHeight(1.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  'p': Style(
                                    margin: Margins.only(bottom: 8),
                                    color: Colors.black.withOpacity(0.92),
                                  ),
                                  'strong': Style(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  'b': Style(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  'ul': Style(
                                    margin: Margins.only(left: 12, bottom: 8),
                                    color: Colors.black.withOpacity(0.92),
                                  ),
                                  'ol': Style(
                                    margin: Margins.only(left: 12, bottom: 8),
                                    color: Colors.black.withOpacity(0.92),
                                  ),
                                  'li': Style(
                                    margin: Margins.only(bottom: 6),
                                    color: Colors.black.withOpacity(0.92),
                                  ),
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              LaunchHelper.whatsapp(
                                AppConstants.whatsapp,
                              );
                            },
                            icon:
                                const Icon(Icons.assignment_turned_in_rounded),
                            label: const Text('Kontak Kami'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 10),
                        // InkWell(
                        //   borderRadius: BorderRadius.circular(18),
                        //   onTap: () => LaunchHelper.whatsapp(
                        //     AppConstants.whatsapp,
                        //   ),
                        //   child: Container(
                        //     height: 50,
                        //     width: 54,
                        //     decoration: BoxDecoration(
                        //       color: AppColors.skyBlue,
                        //       borderRadius: BorderRadius.circular(18),
                        //     ),
                        //     child: const Icon(
                        //       Icons.chat_rounded,
                        //       color: AppColors.primaryBlue,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _TrustNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailHero extends StatelessWidget {
  const _ProductDetailHero({
    required this.product,
    required this.productId,
    required this.productType,
    required this.imageUrl,
    required this.bannerUrl,
  });

  final ProductItem product;
  final String productId;
  final String productType;
  final String? imageUrl;
  final String? bannerUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            Positioned.fill(
              child: bannerUrl == null
                  ? Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.deepBlue,
                            AppColors.primaryRed,
                          ],
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: bannerUrl!,
                      fit: BoxFit.contain,
                    ),
            ),
            // Positioned.fill(
            //   child: Container(
            //     color: Colors.black.withOpacity(0.42),
            //   ),
            // ),
            const Padding(
              padding: EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Isi detail hero kamu taruh di sini.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackLink extends StatelessWidget {
  const _BackLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, color: AppColors.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  const _DetailInfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.skyBlue,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                description,
                style: const TextStyle(
                  color: AppColors.muted,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductTypeGroup {
  const _ProductTypeGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.products,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<ProductItem> products;
  final String? bannerUrl;
}

List<_ProductTypeGroup> _productGroupsFromApi(List<ProductItem> products) {
  final Map<String, List<ProductItem>> grouped = {};

  for (final product in products) {
    final typeName = _productTypeOf(product);
    final typeKey = _productTypeIdOf(product, typeName);
    grouped.putIfAbsent(typeKey, () => <ProductItem>[]).add(product);
  }

  return grouped.entries.map((entry) {
    final firstProduct = entry.value.first;
    final title = _productTypeOf(firstProduct);
    final sampleNames = entry.value
        .take(2)
        .map((product) => product.title)
        .where((title) => title.trim().isNotEmpty)
        .join(', ');
    final subtitle = 'Lihat daftar produk $sampleNames yang tersedia.';

    return _ProductTypeGroup(
      id: entry.key.isEmpty ? productSafeSlug(title) : entry.key,
      title: title,
      subtitle: subtitle,
      icon: _iconForProductType(title),
      products: entry.value,
      bannerUrl: _productBannerUrlOf(firstProduct),
    );
  }).toList();
}

String _productTypeIdOf(ProductItem item, String typeName) {
  final candidates = [
    _dynamicStringOf(item, 'typeId'),
    _dynamicStringOf(item, 'jenisId'),
    _dynamicStringOf(item, 'idJenis'),
    _dynamicStringOf(item, 'categoryId'),
    _dynamicStringOf(item, 'kategoriId'),
    _dynamicStringOf(item, 'productTypeId'),
    _dynamicStringOf(item, 'groupId'),
  ];

  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }

  final fallback = productSafeSlug(typeName);
  return fallback.isEmpty ? 'produk-lainnya' : fallback;
}

String _productTypeOf(ProductItem item) {
  final candidates = [
    _dynamicStringOf(item, 'type'),
    _dynamicStringOf(item, 'jenis'),
    _dynamicStringOf(item, 'jenisProduk'),
    _dynamicStringOf(item, 'category'),
    _dynamicStringOf(item, 'categoryName'),
    _dynamicStringOf(item, 'kategori'),
    _dynamicStringOf(item, 'namaKategori'),
    _dynamicStringOf(item, 'productType'),
    _dynamicStringOf(item, 'productTypeName'),
    _dynamicStringOf(item, 'group'),
    _dynamicStringOf(item, 'groupName'),
  ];

  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) {
      return _titleCase(value);
    }
  }

  final lowerTitle = item.title.toLowerCase();
  if (lowerTitle.contains('kredit') ||
      lowerTitle.contains('pinjaman') ||
      lowerTitle.contains('loan')) {
    return 'Kredit';
  }
  if (lowerTitle.contains('deposito') || lowerTitle.contains('deposit')) {
    return 'Deposito';
  }
  if (lowerTitle.contains('tabungan') || lowerTitle.contains('saving')) {
    return 'Tabungan';
  }

  return 'Produk Lainnya';
}

String _productIdOf(ProductItem item, int index) {
  final candidates = [
    _dynamicStringOf(item, 'id'),
    _dynamicStringOf(item, 'productId'),
    _dynamicStringOf(item, 'produkId'),
    _dynamicStringOf(item, 'kodeProduk'),
    _dynamicStringOf(item, 'code'),
    _dynamicStringOf(item, 'slug'),
  ];

  for (final value in candidates) {
    if (value != null && value.trim().isNotEmpty) return value.trim();
  }

  final slug = productSafeSlug(item.title);
  return slug.isEmpty ? 'product-${index + 1}' : '$slug-${index + 1}';
}

String? _productImageUrlOf(ProductItem item) {
  // Prioritaskan thumbnail dari API, lalu fallback ke banner/image.
  final candidates = [
    _dynamicStringOf(item, 'thumbnail'),
    _dynamicStringOf(item, 'thumbail'),
    _dynamicStringOf(item, 'thumbnailUrl'),
    _dynamicStringOf(item, 'images'),
    _dynamicStringOf(item, 'banner'),
    _dynamicStringOf(item, 'image'),
    _dynamicStringOf(item, 'imageUrl'),
    _dynamicStringOf(item, 'iconUrl'),
  ];

  for (final value in candidates) {
    final imageUrl = _fullApiImageUrl(value);
    if (imageUrl != null && imageUrl.trim().isNotEmpty) return imageUrl;
  }

  return null;
}

String? _productIconUrlOf(ProductItem item) {
  final candidates = [
    _dynamicStringOf(item, 'iconUrl'),
    _dynamicStringOf(item, 'icon'),
    _dynamicStringOf(item, 'icon_url'),
    _dynamicStringOf(item, 'url_icon'),
    _dynamicStringOf(item, 'logo'),
  ];

  for (final value in candidates) {
    final iconUrl = _fullApiImageUrl(value);
    if (iconUrl != null && iconUrl.trim().isNotEmpty) return iconUrl;
  }

  return null;
}

String? _productBannerUrlOf(ProductItem item) {
  debugPrint('product xxx ${item.banner}');
  final candidates = [
    _dynamicStringOf(item, 'banner'),
    _dynamicStringOf(item, 'bannerUrl'),
    _dynamicStringOf(item, 'images'),
    _dynamicStringOf(item, 'image'),
  ];

  for (final value in candidates) {
    final bannerUrl = _fullApiImageUrl(value);
    if (bannerUrl != null && bannerUrl.trim().isNotEmpty) {
      return bannerUrl;
    }
  }

  return null;
}

String? _dynamicStringOf(ProductItem item, String fieldName) {
  final rawValue = _apiValueToString(item.raw[fieldName]);
  if (rawValue != null && rawValue.trim().isNotEmpty) return rawValue.trim();

  try {
    final dynamic raw = item as dynamic;

    switch (fieldName) {
      case 'id':
        return raw.id?.toString();
      case 'productId':
        return raw.productId?.toString();
      case 'produkId':
        return raw.produkId?.toString();
      case 'kodeProduk':
        return raw.kodeProduk?.toString();
      case 'code':
        return raw.code?.toString();
      case 'slug':
        return raw.slug?.toString();
      case 'typeId':
        return raw.typeId?.toString();
      case 'jenisId':
        return raw.jenisId?.toString();
      case 'idJenis':
        return raw.idJenis?.toString();
      case 'categoryId':
        return raw.categoryId?.toString();
      case 'kategoriId':
        return raw.kategoriId?.toString();
      case 'productTypeId':
        return raw.productTypeId?.toString();
      case 'groupId':
        return raw.groupId?.toString();
      case 'type':
        return raw.type?.toString();
      case 'jenis':
        return raw.jenis?.toString();
      case 'jenisProduk':
        return raw.jenisProduk?.toString();
      case 'category':
        return raw.category?.toString();
      case 'categoryName':
        return raw.categoryName?.toString();
      case 'kategori':
        return raw.kategori?.toString();
      case 'namaKategori':
        return raw.namaKategori?.toString();
      case 'productType':
        return raw.productType?.toString();
      case 'productTypeName':
        return raw.productTypeName?.toString();
      case 'group':
        return raw.group?.toString();
      case 'groupName':
        return raw.groupName?.toString();
      case 'imageUrl':
        return raw.imageUrl?.toString();
      case 'image':
        return raw.image?.toString();
      case 'images':
        return raw.images?.toString();
      case 'banner':
        return raw.banner?.toString();
      case 'thumbnail':
        return raw.thumbnail?.toString();
      case 'thumbail':
        return raw.thumbail?.toString();
      case 'thumbnailUrl':
        return raw.thumbnailUrl?.toString();
      case 'iconUrl':
        return raw.iconUrl?.toString();
    }
  } catch (_) {
    // Tetap aman bila model ProductItem belum memiliki field dari API.
  }

  return null;
}

IconData _iconForProductType(String value) {
  final normalized = value.toLowerCase();
// icon kredit, deposito, tabungan
  if (normalized.contains('kredit') ||
      normalized.contains('pinjaman') ||
      normalized.contains('loan')) {
    return Icons.payments_rounded;
  }
  if (normalized.contains('deposito') || normalized.contains('deposit')) {
    return Icons.lock_clock;
  }
  if (normalized.contains('tabungan') || normalized.contains('saving')) {
    return Icons.account_balance_wallet_rounded;
  }
  if (normalized.contains('umkm') || normalized.contains('usaha')) {
    return Icons.store_rounded;
  }

  return Icons.account_balance_rounded;
}

String _titleCase(String value) {
  return value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String productSafeSlug(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

class _NewsPreviewCard extends StatelessWidget {
  const _NewsPreviewCard({required this.article});

  final NewsArticle article;

// section berita
  @override
  Widget build(BuildContext context) {
    final date = DateFormatter.short(article.date);
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: article.bannerUrl == null
                ? Container(
                    width: 78,
                    height: 78,
                    color: AppColors.skyBlue,
                    child: const Icon(Icons.newspaper_rounded,
                        color: AppColors.primaryBlue),
                  )
                : CachedNetworkImage(
                    imageUrl: article.bannerUrl!,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 78,
                      height: 78,
                      color: AppColors.skyBlue,
                      child: const Icon(Icons.newspaper_rounded,
                          color: AppColors.primaryBlue),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  article.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12, height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.skyBlue,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppConstants.ojkLpsNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.deepBlue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const ResponsiveContainer(
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          BrandHeader(),
          SizedBox(height: 18),
          AppCard(
              child: SizedBox(
                  height: 170,
                  child: Center(child: CircularProgressIndicator()))),
          SizedBox(height: 12),
          AppCard(child: SizedBox(height: 88)),
        ],
      ),
    );
  }
}

String stripHtml(String value) {
  return value.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}
