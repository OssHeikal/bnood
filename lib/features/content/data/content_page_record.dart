class ContentPage {
  const ContentPage({
    required this.slug,
    required this.locale,
    required this.title,
    required this.body,
    required this.format,
    required this.updatedAt,
  });

  final String slug;
  final String locale;
  final String title;
  final String body;
  final String format;
  final DateTime updatedAt;

  factory ContentPage.fromDataJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw const FormatException('Missing page payload');
    }
    return ContentPage(
      slug: json['slug'] as String,
      locale: json['locale'] as String? ?? 'ar',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      format: json['format'] as String? ?? 'html',
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
    );
  }
}

abstract final class ContentSlugs {
  static const about = 'about';
  static const terms = 'terms';
  static const privacy = 'privacy';
  static const cancellation = 'cancellation';
}

abstract final class ContentPaths {
  static String page(String slug) => '/pages/$slug';
  static const about = '/pages/about';
  static const terms = '/pages/terms';
  static const privacy = '/pages/privacy';
  static const cancellation = '/pages/cancellation';
}
