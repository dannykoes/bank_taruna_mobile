import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/launch_helper.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ResponsiveContainer(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(subtitle: 'Profil dan kontak resmi'),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.primaryRed]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.account_balance_rounded, color: Colors.white, size: 42),
                    const SizedBox(height: 14),
                    Text(
                      AppConstants.bankName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.ojkLpsNote,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Visi & Misi',
                subtitle: 'Ringkasan profil dari website Bank Taruna.',
              ),
              const SizedBox(height: 12),
              const _VisionMissionCard(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Nilai Layanan'),
              const SizedBox(height: 12),
              const _ValueGrid(),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Hubungi Kami'),
              const SizedBox(height: 12),
              _ContactCard(),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => LaunchHelper.openUrl(AppConstants.baseUrl),
                icon: const Icon(Icons.language_rounded),
                label: const Text('Buka Website Resmi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VisionMissionCard extends StatelessWidget {
  const _VisionMissionCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniTitle(icon: Icons.visibility_rounded, title: 'Visi'),
          SizedBox(height: 10),
          Text(
            'Menjadi BPR yang Bersih, Sehat, dan Terpercaya.',
            style: TextStyle(fontWeight: FontWeight.w800, height: 1.4),
          ),
          SizedBox(height: 20),
          _MiniTitle(icon: Icons.flag_rounded, title: 'Misi'),
          SizedBox(height: 10),
          _MissionText('Memberikan pelayanan terbaik kepada nasabah serta berperan aktif membantu pemerintah dalam pengembangan UMKM.'),
          _MissionText('Meningkatkan kinerja BPR yang sehat, kuat, efisien, profesional, dan berkesinambungan.'),
          _MissionText('Memberikan pengetahuan tentang manajemen keuangan kepada nasabah.'),
          _MissionText('Menjadikan pemasaran sebagai konsultan keuangan dan produk bagi nasabah.'),
        ],
      ),
    );
  }
}

class _MissionText extends StatelessWidget {
  const _MissionText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 6, color: AppColors.primaryRed),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _MiniTitle extends StatelessWidget {
  const _MiniTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}

class _ValueGrid extends StatelessWidget {
  const _ValueGrid();

  static const values = [
    ('Service Excellence', 'Pelayanan prima kepada nasabah.', Icons.support_agent_rounded),
    ('Target Oriented', 'Orientasi pada pencapaian target.', Icons.track_changes_rounded),
    ('Accountability', 'Bertanggung jawab sesuai ketentuan.', Icons.verified_rounded),
    ('Reliable', 'Dapat diandalkan untuk menyelesaikan pekerjaan.', Icons.handshake_rounded),
    ('Synergy', 'Membangun kerja sama yang baik.', Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 560;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values.map((value) {
            return SizedBox(
              width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.skyBlue, borderRadius: BorderRadius.circular(16)),
                      child: Icon(value.$3, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(value.$2, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _ContactTile(
            icon: Icons.phone_rounded,
            title: 'Telepon',
            value: AppConstants.phone,
            onTap: () => LaunchHelper.phone(AppConstants.phone),
          ),
          const Divider(height: 22),
          _ContactTile(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            value: AppConstants.whatsappDisplay,
            onTap: () => LaunchHelper.whatsapp(AppConstants.whatsapp),
          ),
          const Divider(height: 22),
          _ContactTile(
            icon: Icons.email_rounded,
            title: 'Email',
            value: AppConstants.email,
            onTap: () => LaunchHelper.email(AppConstants.email),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.icon, required this.title, required this.value, required this.onTap});

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.skyBlue, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
