import 'package:bnood/core/network/api/pages_api.dart';
import 'package:bnood/features/content/data/content_page_record.dart';

class StubPagesApi extends PagesApi {
  StubPagesApi(this._handler) : super();

  final Future<ContentPage> Function({
    required String slug,
    required String locale,
  })
  _handler;

  @override
  Future<ContentPage> getPage({required String slug, required String locale}) =>
      _handler(slug: slug, locale: locale);
}
