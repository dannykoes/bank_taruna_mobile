import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/launch_helper.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';
import '../home/home_data.dart';
import '../home/home_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider).maybeWhen(
          data: (data) => data,
          orElse: () => null,
        );
    final profileText = homeData?.profileText ?? HomeData.defaultProfileText;
    final visionMissionText =
        homeData?.visionMissionText ?? HomeData.defaultVisionMissionText;
    final visionText = homeData?.visionText ?? HomeData.defaultVisionText;
    final missionTexts = homeData?.missionTexts ?? HomeData.defaultMissionTexts;
    final starsValues = homeData?.starsValues ?? HomeData.defaultStarsValues;
    final contactPhone = homeData?.contactPhone ?? AppConstants.phone;
    final contactWhatsapp = homeData?.contactWhatsapp ?? AppConstants.whatsapp;
    final contactWhatsappDisplay =
        homeData?.contactWhatsappDisplay ?? AppConstants.whatsappDisplay;
    final contactEmail = homeData?.contactEmail ?? AppConstants.email;

    return ListView(
      children: [
        ResponsiveContainer(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(subtitle: 'Profil dan kontak resmi'),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: CustomPaint(painter: _ProfileHeroPainter()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.account_balance_rounded,
                                color: Colors.white, size: 42),
                            const SizedBox(height: 14),
                            Text(
                              AppConstants.bankName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profileText,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Visi & Misi',
                subtitle: 'Ringkasan profil dari website Bank Taruna.',
              ),
              const SizedBox(height: 12),
              _VisionMissionCard(
                visionMissionText: visionMissionText,
                visionText: visionText,
                missionTexts: missionTexts,
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Nilai Layanan'),
              const SizedBox(height: 12),
              _ValueGrid(values: starsValues),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Hubungi Kami'),
              const SizedBox(height: 12),
              _ContactCard(
                phone: contactPhone,
                whatsapp: contactWhatsapp,
                whatsappDisplay: contactWhatsappDisplay,
                email: contactEmail,
              ),
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

class _ProfileHeroPainter extends CustomPainter {
  const _ProfileHeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryBlue,
          Color(0xFF3157D9),
          AppColors.primaryRed,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final redOrbPaint = Paint()
      ..color = AppColors.primaryRed.withValues(alpha: 0.78);
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.22),
      size.shortestSide * 0.42,
      redOrbPaint,
    );

    final blueOrbPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.88),
      size.shortestSide * 0.36,
      blueOrbPaint,
    );

    final ribbonPaint = Paint()..color = Colors.white.withValues(alpha: 0.16);
    final ribbon = Path()
      ..moveTo(size.width * 0.36, 0)
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.28,
        size.width,
        size.height * 0.18,
      )
      ..lineTo(size.width, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.52,
        size.width * 0.28,
        0,
      )
      ..close();
    canvas.drawPath(ribbon, ribbonPaint);

    final cardPaint = Paint()..color = Colors.white.withValues(alpha: 0.18);
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.64,
        size.height * 0.48,
        size.width * 0.26,
        size.height * 0.2,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(cardRect, cardPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.69, size.height * 0.58),
      Offset(size.width * 0.84, size.height * 0.58),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VisionMissionCard extends StatelessWidget {
  const _VisionMissionCard({
    required this.visionMissionText,
    required this.visionText,
    required this.missionTexts,
  });

  final String visionMissionText;
  final String visionText;
  final List<String> missionTexts;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (visionMissionText.trim().isNotEmpty) ...[
            const _MiniTitle(icon: Icons.flag_rounded, title: 'Visi & Misi'),
            const SizedBox(height: 10),
            Text(
              visionMissionText,
              style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4),
            ),
          ] else ...[
            const _MiniTitle(icon: Icons.visibility_rounded, title: 'Visi'),
            const SizedBox(height: 10),
            Text(
              visionText,
              style: const TextStyle(fontWeight: FontWeight.w800, height: 1.4),
            ),
            const SizedBox(height: 20),
            const _MiniTitle(icon: Icons.flag_rounded, title: 'Misi'),
            const SizedBox(height: 10),
            ...missionTexts.map((mission) => _MissionText(mission)),
          ],
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
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}

class _ValueGrid extends StatelessWidget {
  const _ValueGrid({required this.values});

  final List<HomeStarsValue> values;

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
              width: isWide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth,
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.skyBlue,
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(value.icon, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(value.description,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 12.5)),
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
  const _ContactCard({
    required this.phone,
    required this.whatsapp,
    required this.whatsappDisplay,
    required this.email,
  });

  final String phone;
  final String whatsapp;
  final String whatsappDisplay;
  final String email;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _ContactTile(
            icon: Icons.phone_rounded,
            title: 'Telepon',
            value: phone,
            onTap: () => LaunchHelper.phone(phone),
          ),
          const Divider(height: 22),
          _ContactTile(
            icon: Icons.chat_rounded,
            title: 'WhatsApp',
            value: whatsappDisplay,
            onTap: () => LaunchHelper.whatsapp(whatsapp),
          ),
          const Divider(height: 22),
          _ContactTile(
            icon: Icons.email_rounded,
            title: 'Email',
            value: email,
            onTap: () => LaunchHelper.email(email),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile(
      {required this.icon,
      required this.title,
      required this.value,
      required this.onTap});

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
              decoration: BoxDecoration(
                  color: AppColors.skyBlue,
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                  Text(value,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
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
