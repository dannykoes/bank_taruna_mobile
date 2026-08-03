import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/utils/html_cleaner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/launch_helper.dart';
import '../../core/widgets/responsive_container.dart';
import 'news_article.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({super.key, required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final date = DateFormatter.short(article.date);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          if (article.link.isNotEmpty)
            IconButton(
              onPressed: () => LaunchHelper.openUrl(article.link),
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: 'Buka website',
            ),
        ],
      ),
      body: ListView(
        children: [
          if (article.bannerUrl != null)
            CachedNetworkImage(
              imageUrl: article.bannerUrl!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.fill,
            )
          else
            Container(
              height: 180,
              color: AppColors.skyBlue,
              child: const Icon(Icons.newspaper_rounded,
                  color: AppColors.primaryBlue, size: 64),
            ),
          ResponsiveContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date,
                    style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900, height: 1.16),
                ),
                const SizedBox(height: 18),
                Text(
                  article.content.isNotEmpty
                      ? HtmlCleaner.text(article.content)
                      : article.excerpt,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.55, color: AppColors.ink),
                ),
                if (article.link.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => LaunchHelper.openUrl(article.link),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Baca di Website'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
