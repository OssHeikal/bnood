import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/clients/client_detail_screen.dart';
import '../features/clients/clients_list_screen.dart';
import '../features/clients/client_craftsmen_list_screen.dart';
import '../features/clients/client_items_stats_screen.dart';
import '../features/clients/movements_list_screen.dart';
import '../features/statements/supplier_statement_screen.dart';
import '../features/home/home_screen.dart';
import '../features/items/items_screen.dart';
import '../features/statements/client_statement_screen.dart';
import '../features/suppliers/craftsman_detail_screen.dart';
import '../features/suppliers/directory_screen.dart';
import '../features/suppliers/supplier_detail_screen.dart';
import 'bnood_splash_session.dart';
import 'bnood_startup_splash.dart';
import 'shell_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

String? _splashRedirect(GoRouterState state) {
  final onSplash = state.matchedLocation == BnoodStartupSplashPage.path;
  if (BnoodSplashSession.completed) {
    return onSplash ? BnoodStartupSplashPage.handoffLocation : null;
  }
  return onSplash ? null : BnoodStartupSplashPage.path;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: BnoodSplashSession.completed
        ? BnoodStartupSplashPage.handoffLocation
        : BnoodStartupSplashPage.path,
    redirect: (_, state) => _splashRedirect(state),
    routes: [
      GoRoute(
        path: BnoodStartupSplashPage.path,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const BnoodStartupSplashPage(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, navigationShell) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ShellScaffold(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: BnoodStartupSplashPage.handoffLocation,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                builder: (_, _) => const ClientsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/directory',
                builder: (_, state) {
                  final tab = state.uri.queryParameters['tab'];
                  return DirectoryScreen(
                    initialTabIndex: tab == 'craftsmen' ? 1 : 0,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/items', builder: (_, _) => const ItemsScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/clients/:clientId',
        builder: (_, state) =>
            ClientDetailScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/movements',
        builder: (_, state) =>
            MovementsListScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/craftsmen',
        builder: (_, state) => ClientCraftsmenListScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/clients/:clientId/items',
        builder: (_, state) =>
            ClientItemsStatsScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/statement',
        builder: (_, state) =>
            ClientStatementScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/suppliers/:supplierId',
        builder: (_, state) => SupplierDetailScreen(
          supplierId: state.pathParameters['supplierId']!,
        ),
      ),
      GoRoute(
        path: '/suppliers/:supplierId/statement',
        builder: (_, state) => SupplierStatementScreen(
          supplierId: state.pathParameters['supplierId']!,
        ),
      ),
      GoRoute(
        path: '/craftsmen/:craftsmanId',
        builder: (_, state) => CraftsmanDetailScreen(
          craftsmanId: state.pathParameters['craftsmanId']!,
        ),
      ),
    ],
  );
});
