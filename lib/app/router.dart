import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_bootstrap_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_paths.dart';
import '../features/auth/auth_state.dart';
import '../features/auth/change_password_screen.dart';
import '../features/auth/complete_profile_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/forgot_verify_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/register_verify_screen.dart';
import '../features/auth/remote_workspace_screen.dart';
import '../features/auth/user_profile_screen.dart';
import '../features/settings/app_settings_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/clients/client_detail_screen.dart';
import '../features/clients/clients_list_screen.dart';
import '../features/clients/client_craftsmen_list_screen.dart';
import '../features/clients/client_items_stats_screen.dart';
import '../features/clients/movements_list_screen.dart';
import '../features/statements/supplier_statement_screen.dart';
import '../features/home/home_screen.dart';
import '../features/statements/client_statement_screen.dart';
import '../features/providers/provider_detail_screen.dart';
import '../features/suppliers/craftsman_detail_screen.dart';
import 'app_shell_directory_body.dart';
import '../features/suppliers/supplier_detail_screen.dart';
import 'auth_router_refresh.dart';
import 'app_splash_session.dart';
import 'app_startup_splash.dart';
import 'app_shell_items_body.dart';
import 'app_shell_online_tabs.dart';
import 'app_shell_tab_gate.dart';
import 'shell_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

const _localHome = '/home';

String? _splashRedirect(GoRouterState state) {
  final onSplash = state.matchedLocation == AppStartupSplashPage.path;
  if (AppSplashSession.completed) {
    return onSplash ? AuthPaths.login : null;
  }
  return onSplash ? null : AppStartupSplashPage.path;
}

String? _authRedirect(Ref ref, GoRouterState state) {
  final splash = _splashRedirect(state);
  if (splash != null) return splash;

  final auth = ref.read(authControllerProvider);
  final loc = state.matchedLocation;

  if (loc == AuthPaths.bootstrap) {
    if (auth.isAuthenticated && auth.user != null) {
      return authenticatedHomeFor(auth.user!);
    }
    if (auth.bootstrapStatus == AuthBootstrapStatus.unauthenticated) {
      return AuthPaths.login;
    }
    return null;
  }

  if (auth.isAuthenticated && auth.user != null) {
    final home = authenticatedHomeFor(auth.user!);
    final needsProfile = userNeedsProfileCompletion(auth.user);
    if (needsProfile && loc != AuthPaths.completeProfile && loc != AuthPaths.changePassword) {
      return AuthPaths.completeProfile;
    }
    if (!needsProfile && loc == AuthPaths.completeProfile) {
      return home;
    }
    if (loc == AuthPaths.remote) {
      return home;
    }
    if (isLocalLedgerLocation(loc) || loc == AuthPaths.login) {
      return home;
    }
    if (isAuthFlowLocation(loc) && loc != AuthPaths.changePassword && loc != AuthPaths.completeProfile) {
      return home;
    }
  } else {
    if (loc == AuthPaths.remote ||
        loc == AuthPaths.changePassword ||
        loc == AuthPaths.completeProfile ||
        isLocalLedgerLocation(loc)) {
      return AuthPaths.login;
    }
  }

  return null;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);
  return GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootKey,
    observers: [BotToastNavigatorObserver()],
    refreshListenable: refresh,
    initialLocation: AppSplashSession.completed ? AuthPaths.login : AppStartupSplashPage.path,
    redirect: (_, state) => _authRedirect(ref, state),
    routes: [
      GoRoute(
        path: AppStartupSplashPage.path,
        pageBuilder: (_, state) => NoTransitionPage<void>(key: state.pageKey, child: const AppStartupSplashPage()),
      ),
      GoRoute(
        path: AuthPaths.bootstrap,
        pageBuilder: (_, state) => NoTransitionPage<void>(key: state.pageKey, child: const AuthBootstrapScreen()),
      ),
      GoRoute(
        path: AuthPaths.login,
        pageBuilder: (_, state) => NoTransitionPage<void>(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(path: AuthPaths.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: AuthPaths.registerVerify, builder: (_, _) => const RegisterVerifyScreen()),
      GoRoute(
        path: AuthPaths.completeProfile,
        pageBuilder: (_, state) => NoTransitionPage<void>(key: state.pageKey, child: const CompleteProfileScreen()),
      ),
      GoRoute(path: AuthPaths.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(path: AuthPaths.forgotVerify, builder: (_, _) => const ForgotVerifyScreen()),
      GoRoute(path: AuthPaths.resetPassword, builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(path: AuthPaths.changePassword, builder: (_, _) => const ChangePasswordScreen()),
      GoRoute(path: AuthPaths.remote, builder: (_, _) => const RemoteWorkspaceScreen()),
      GoRoute(path: AuthPaths.profile, builder: (_, _) => const UserProfileScreen()),
      GoRoute(path: AuthPaths.settings, builder: (_, _) => const AppSettingsScreen()),
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
                path: _localHome,
                builder: (_, _) => const AppShellTabGate(tab: AppShellTabId.home, child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                builder: (_, _) => const AppShellTabGate(tab: AppShellTabId.clients, child: ClientsListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/directory',
                builder: (_, state) {
                  final tab = state.uri.queryParameters['tab'];
                  return AppShellTabGate(
                    tab: AppShellTabId.directory,
                    child: AppShellDirectoryBody(initialTabIndex: tab == 'craftsmen' ? 1 : 0),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/items',
                builder: (_, _) => const AppShellTabGate(tab: AppShellTabId.items, child: AppShellItemsBody()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/clients/:clientId',
        builder: (_, state) => ClientDetailScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/movements',
        builder: (_, state) => MovementsListScreen(
          clientId: state.pathParameters['clientId']!,
          itemId: state.uri.queryParameters['item_id'],
        ),
      ),
      GoRoute(
        path: '/clients/:clientId/craftsmen',
        builder: (_, state) => ClientCraftsmenListScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/items',
        builder: (_, state) => ClientItemsStatsScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/clients/:clientId/statement',
        builder: (_, state) => ClientStatementScreen(clientId: state.pathParameters['clientId']!),
      ),
      GoRoute(
        path: '/providers/:providerId',
        builder: (_, state) => ProviderDetailScreen(providerId: state.pathParameters['providerId']!),
      ),
      GoRoute(
        path: '/suppliers/:supplierId',
        builder: (_, state) => SupplierDetailScreen(supplierId: state.pathParameters['supplierId']!),
      ),
      GoRoute(
        path: '/suppliers/:supplierId/statement',
        builder: (_, state) => SupplierStatementScreen(supplierId: state.pathParameters['supplierId']!),
      ),
      GoRoute(
        path: '/craftsmen/:craftsmanId',
        builder: (_, state) => CraftsmanDetailScreen(craftsmanId: state.pathParameters['craftsmanId']!),
      ),
    ],
  );
});
