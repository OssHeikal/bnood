import 'package:bnood/app/router.dart';
import 'package:bnood/core/config/navigation/root_navigator_key.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'production GoRouter uses the shared rootNavigatorKey (AppToaster layout context)',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(goRouterProvider);
      expect(
        identical(router.routerDelegate.navigatorKey, rootNavigatorKey),
        isTrue,
      );
      router.dispose();
    },
  );
}
