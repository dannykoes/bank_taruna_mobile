import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';
import 'news_article.dart';
import 'news_detail_screen.dart';
import 'news_repository.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final news = ref.watch(latestNewsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(latestNewsProvider),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(subtitle: 'Berita dan literasi keuangan'),
                  const SizedBox(height: 22),
                  const SectionHeader(
                    title: 'Informasi Terbaru',
                    subtitle: 'Konten diambil dari website Taruna.',
                  ),
                  const SizedBox(height: 14),
                  news.when(
                    data: (items) => items.isEmpty
                        ? const EmptyState(
                            title: 'Belum ada berita',
                            message: 'Data berita belum tersedia dari server.',
                          )
                        : Column(
                            children: items
                                .map((article) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: NewsCard(article: article),
                                    ))
                                .toList(),
                          ),
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => ErrorState(
                      message: 'Berita belum dapat dimuat. ${error.toString()}',
                      onRetry: () => ref.invalidate(latestNewsProvider),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final date = DateFormatter.short(article.date);
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => NewsDetailScreen(article: article)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: article.bannerUrl == null
                ? Container(
                    height: 154,
                    width: double.infinity,
                    color: AppColors.skyBlue,
                    child: const Icon(Icons.newspaper_rounded,
                        color: AppColors.primaryBlue, size: 48),
                  )
                : CachedNetworkImage(
                    imageUrl: article.bannerUrl!,
                    height: 154,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      height: 154,
                      color: AppColors.skyBlue,
                      child: const Icon(Icons.newspaper_rounded,
                          color: AppColors.primaryBlue, size: 48),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.softRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                            color: AppColors.primaryRed,
                            fontWeight: FontWeight.w800,
                            fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(date,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  article.excerpt,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
