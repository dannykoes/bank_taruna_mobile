import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/providers.dart';
import 'news_article.dart';

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(ref.watch(dioProvider));
});

final latestNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  return ref.watch(newsRepositoryProvider).fetchLatestNews(limit: 12);
});

class NewsRepository {
  const NewsRepository(this._dio);

  final Dio _dio;

  Future<List<NewsArticle>> fetchLatestNews({int limit = 10}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.allberita,
      queryParameters: {'per_page': limit},
    );

    final body = response.data ?? <String, dynamic>{};
    if (body['success'] == false) {
      throw ApiException(body['message']?.toString() ?? 'Berita gagal dimuat.');
    }

    final data = _beritaData(body);

    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => NewsArticle.fromApi(Map<String, dynamic>.from(item)))
        .toList();
  }

  Object? _beritaData(Map<String, dynamic> body) {
    final berita = body['berita'];
    if (berita is Map && berita['data'] is List) return berita['data'];
    if (berita is List) return berita;

    final data = body['data'];
    if (data is Map && data['berita'] is Map) {
      return (data['berita'] as Map)['data'];
    }
    if (data is Map && data['berita'] is List) return data['berita'];

    return null;
  }
}
