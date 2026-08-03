class BannerItem {
  const BannerItem({
    required this.title,
    required this.subtitle,
    required this.cta,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String cta;
  final String? imageUrl;
}
