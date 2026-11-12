import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/auth_api_exception.dart';
import '../../core/api/pages_api.dart';
import '../../core/content/content_page_record.dart';
import '../../core/providers/settings_provider.dart';

final pagesApiProvider = Provider<PagesApi>((ref) {
  final api = PagesApi();
  ref.onDispose(api.close);
  return api;
});

final contentPageProvider =
    FutureProvider.family<ContentPage, String>((ref, slug) async {
  final locale = ref.watch(localeProvider).languageCode;
  try {
    return await ref.read(pagesApiProvider).getPage(slug: slug, locale: locale);
  } on AuthApiException catch (e) {
    if (e.statusCode == 404) {
      throw ContentPageNotFoundException(slug);
    }
    rethrow;
  }
});

class ContentPageNotFoundException implements Exception {
  ContentPageNotFoundException(this.slug);
  final String slug;
}
