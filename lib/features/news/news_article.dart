import '../../core/constants/app_constants.dart';
import '../../core/utils/html_cleaner.dart';

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.link,
    this.imageUrl,
    this.bannerUrl,
    this.category = 'Informasi',
  });

  final int id;
  final String title;
  final String excerpt;
  final String content;
  final DateTime date;
  final String link;
  final String? imageUrl;
  final String? bannerUrl;
  final String category;

  factory NewsArticle.fromWordPress(Map<String, dynamic> json) {
    final embedded = json['_embedded'];
    String? image;
    if (json['jetpack_featured_media_url'] is String &&
        (json['jetpack_featured_media_url'] as String).isNotEmpty) {
      image = json['jetpack_featured_media_url'] as String;
    } else if (embedded is Map && embedded['wp:featuredmedia'] is List) {
      final media = embedded['wp:featuredmedia'] as List;
      if (media.isNotEmpty && media.first is Map) {
        final first = media.first as Map;
        image = first['source_url'] as String?;
      }
    }

    return NewsArticle(
      id: json['id'] as int? ?? 0,
      title: HtmlCleaner.text(json['title']?['rendered']?.toString()),
      excerpt: HtmlCleaner.text(json['excerpt']?['rendered']?.toString()),
      content: HtmlCleaner.text(json['content']?['rendered']?.toString()),
      date: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      link: json['link']?.toString() ?? '',
      imageUrl: image,
    );
  }

  factory NewsArticle.fromApi(Map<String, dynamic> json) {
    final title = HtmlCleaner.text(_stringValue(json, [
      'title',
      'judul',
      'name',
      'nama',
      'headline',
    ]));
    final content = HtmlCleaner.text(_stringValue(json, [
      'content',
      'isi',
      'body',
      'deskripsi',
      'description',
    ]));
    final excerpt = HtmlCleaner.text(
      _stringValue(
              json, ['excerpt', 'ringkasan', 'deskripsi', 'description']) ??
          content,
    );

    return NewsArticle(
      id: _intValue(json['id']),
      title: title.isNotEmpty ? title : 'Berita',
      excerpt: excerpt,
      content: content,
      date: DateTime.tryParse(
            _stringValue(json, [
                  'published_at',
                  'tanggal',
                  'tgl',
                  'created_at',
                  'updated_at',
                ]) ??
                '',
          ) ??
          DateTime.now(),
      link: _stringValue(json, ['link', 'url', 'slug']) ?? '',
      imageUrl: _fileUrl(_stringValue(json, [
        'thumbnail',
        'thumb',
        'image',
        'gambar',
        'foto',
        'url_thumbnail',
      ])),
      bannerUrl: _fileUrl(_stringValue(json, ['banner', 'url_banner'])),
      category: _categoryValue(json['category'] ?? json['kategori']),
    );
  }

  static String? _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return null;
  }

  static String _categoryValue(Object? value) {
    if (value is Map) {
      final category = _stringValue(Map<String, dynamic>.from(value), [
        'name',
        'nama',
        'title',
        'judul',
      ]);
      return category ?? 'Berita';
    }

    final category = value?.toString().trim();
    if (category == null || category.isEmpty || category == 'null') {
      return 'Berita';
    }
    return category;
  }

  static int _intValue(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String? _fileUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      value = value.replaceAll('${AppConstants.baseUrl}storage',
          '${AppConstants.baseUrl}recfil?display=true&rf=');
      return value;
    }
    return '${AppConstants.baseUrl}recfil?display=true&rf=$value';
  }
}
