import 'package:bank_taruna_mobile/core/utils/launch_helper.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'umkm_screen.dart';
import '../../core/constants/app_constants.dart';

class UmkmDetailPage extends StatelessWidget {
  final UmkmModel item;

  const UmkmDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        title: Text(item.nama),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xffE53935),
                Color(0xff1565C0),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (item.gambar.isNotEmpty) ...[
              SizedBox(
                height: 240,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 240,
                    autoPlay: true,
                    enlargeCenterPage: false,
                    viewportFraction: 1,
                  ),
                  items: item.gambar.map((url) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.network(
                        '${AppConstants.baseUrl}recfil?display=true&rf=$url',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.store, size: 80),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              )
            ] else ...[
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffE53935),
                      Color(0xff1565C0),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.store,
                  size: 110,
                  color: Colors.white,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: Text(item.nama),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text("Jam Buka"),
                        subtitle: Text(item.jam),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text("Alamat"),
                        subtitle: Text(item.alamat),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.star),
                        title: const Text("Rating"),
                        subtitle: Text(item.rating.toString()),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1565C0),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            LaunchHelper.whatsapp(item.telp,
                                text: 'Halo ${item.nama}');
                          },
                          icon: const Icon(Icons.call),
                          label: const Text("Hubungi UMKM"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
