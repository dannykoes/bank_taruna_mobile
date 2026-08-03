import 'dart:convert';

import 'package:bank_taruna_mobile/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'umkm_detail_page.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/app_card.dart';

class UmkmModel {
  final String nama;
  final String jam;
  final String alamat;
  final double rating;
  final String thumbnail;
  final String telp;
  // final String gambar;
  final List<String> gambar;

  UmkmModel({
    required this.nama,
    required this.jam,
    required this.alamat,
    required this.rating,
    required this.thumbnail,
    required this.telp,
    required this.gambar,
  });
}

class UmkmPage extends StatefulWidget {
  const UmkmPage({super.key});

  @override
  State<UmkmPage> createState() => _UmkmPageState();
}

class _UmkmPageState extends State<UmkmPage> {
  List<UmkmModel> data = [
    // UmkmModel(
    //   nama: "Bakso Pak Slamet",
    //   jam: "Kuliner",
    //   alamat: "Boja, Kendal",
    //   rating: 4.9,
    //   thumbnail: "assets/images/bakso_pak_slamet.jpg",
    //   gambar: "assets/images/bakso_pak_slamet_full.jpg",
    // ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await ApiClient.createDio().get(ApiEndpoints.umkmdata);
      // Proses data dari response jika diperlukan

      var body = response.data;
      var statuscode = response.statusCode;
      debugPrint('Data UMKM berhasil dimuat: $body');

      if (statuscode == 200) {
        setState(() {
          data = (body['umkmitem'] as List).map((item) {
            var img = item['gambar'] ?? [];
            var thbl = item['thumbnail'] ?? '';
            if (thbl.isNotEmpty) {
              thbl = item['thumbnail'].replaceAll(
                  '${AppConstants.baseUrl}storage/',
                  '${AppConstants.baseUrl}recfil?display=true&rf=');
            }
            if (img.isNotEmpty) {
              img = jsonDecode(item['gambar']
                  .replaceAll('${AppConstants.baseUrl}storage/', ''));
            }
            debugPrint('Thumbnail: $thbl');
            debugPrint('Imagesnih: $img');
            return UmkmModel(
              nama: item['judul'].toString().toUpperCase(),
              jam: '${item['jam_buka']} - ${item['jam_tutup']}',
              alamat: item['alamat'] ?? '',
              rating: double.tryParse(item['rating'].toString()) ?? 0.0,
              thumbnail: thbl,
              // gambar: [],
              gambar: (img as List).map((e) {
                var imageUrl = e.toString();
                // if (imageUrl.isNotEmpty) {
                //   imageUrl = imageUrl.replaceAll(
                //       'https://banktaruna.com/storage/',
                //       'https://banktaruna.com/recfil?display=true&rf=');
                // }
                return imageUrl;
              }).toList(),
              telp: item['no_telp'] ?? '',
            );
          }).toList();
        });
      } else {
        // Jika status code bukan 200, berarti ada masalah
        debugPrint('Gagal memuat data UMKM: $statuscode');
      }
    } catch (e) {
      debugPrint('Data UMKM berhasil dimuat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.redAccent,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ResponsiveContainer(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BrandHeader(
                  subtitle: 'Usaha Mikro, Kecil, dan Menengah',
                ),
                const SizedBox(height: 22),
                const SectionHeader(
                  title: 'UMKM',
                  subtitle:
                      'Berbagai UMKM yang dapat Anda temukan di sekitar Anda',
                ),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: List.generate(
                      data.length,
                      (index) => _buildItem(context, data[index]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, UmkmModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UmkmDetailPage(item: item),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffFF6B81),
                      Color(0xffFF8A65),
                    ],
                  ),
                ),
                child: Image.network(
                  item.thumbnail,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        item.jam,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.alamat,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Container(
              //   height: 42,
              //   width: 42,
              //   decoration: BoxDecoration(
              //     color: Colors.red.shade50,
              //     borderRadius: BorderRadius.circular(14),
              //   ),
              //   child: Icon(
              //     Icons.arrow_forward_ios_rounded,
              //     size: 18,
              //     color: Colors.red.shade400,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
