import 'package:bnood/core/utils/arabic_search_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps alif variants and ta marbuta', () {
    expect(ArabicSearchNormalizer.normalize('ألومي'), ArabicSearchNormalizer.normalize('الومي'));
    expect(ArabicSearchNormalizer.normalize('إسلام'), ArabicSearchNormalizer.normalize('اسلام'));
    expect(ArabicSearchNormalizer.normalize('آلة'), ArabicSearchNormalizer.normalize('اله'));
    expect(ArabicSearchNormalizer.normalize('فاطمة'), ArabicSearchNormalizer.normalize('فاطمه'));
  });

  test('maps ya variants and strips harakat', () {
    expect(ArabicSearchNormalizer.normalize('ئ'), ArabicSearchNormalizer.normalize('ي'));
    expect(ArabicSearchNormalizer.normalize('على'), ArabicSearchNormalizer.normalize('علي'));
  });

  test('matches bidirectionally for example query', () {
    expect(ArabicSearchNormalizer.matches(query: 'ألومي', haystack: 'الوميتال'), isTrue);
    expect(ArabicSearchNormalizer.matches(query: 'الومي', haystack: 'ألومي مورد'), isTrue);
    expect(ArabicSearchNormalizer.matches(query: 'steel', haystack: 'Steel Co'), isTrue);
  });

  test('leaves digits unchanged for phone matching', () {
    expect(ArabicSearchNormalizer.normalize('01012345678'), '01012345678');
    expect(
      ArabicSearchNormalizer.matches(query: '0101', haystack: '01012345678'),
      isTrue,
    );
  });
}
