import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bnood/features/auth/auth_bootstrap_screen.dart';
import 'package:bnood/features/auth/auth_controller.dart';
import 'package:bnood/features/auth/auth_paths.dart';
import 'package:bnood/features/auth/auth_state.dart';
import 'package:bnood/features/auth/change_password_screen.dart';
import 'package:bnood/features/auth/complete_profile_screen.dart';
import 'package:bnood/features/auth/forgot_password_screen.dart';
import 'package:bnood/features/auth/forgot_verify_screen.dart';
import 'package:bnood/features/auth/login_screen.dart';
import 'package:bnood/features/auth/register_screen.dart';
import 'package:bnood/features/auth/register_verify_screen.dart';
import 'package:bnood/features/auth/remote_workspace_screen.dart';
import 'package:bnood/features/auth/user_profile_screen.dart';
import 'package:bnood/features/app_gate/app_force_update_screen.dart';
import 'package:bnood/features/app_gate/app_gate_paths.dart';
import 'package:bnood/features/app_gate/app_maintenance_screen.dart';
import 'package:bnood/features/app_gate/app_optional_update_screen.dart';
import 'package:bnood/features/content/presentation/screens/content_page_screen.dart';
import 'package:bnood/features/settings/presentation/screens/app_preferences_screen.dart';
import 'package:bnood/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:bnood/features/settings/presentation/screens/more_screen.dart';
import 'package:bnood/features/notifications/presentation/screens/notifications_inbox_placeholder_screen.dart';
import 'package:bnood/features/items/presentation/screens/items_screen.dart';
import 'package:bnood/features/auth/reset_password_screen.dart';
import 'package:bnood/features/clients/presentation/screens/client_detail_screen.dart';
import 'package:bnood/features/clients/presentation/screens/clients_list_screen.dart';
import 'package:bnood/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:bnood/features/projects/presentation/screens/projects_list_screen.dart';
import 'package:bnood/features/clients/presentation/screens/client_craftsmen_list_screen.dart';
import 'package:bnood/features/providers/presentation/screens/client_suppliers_list_screen.dart';
import 'package:bnood/features/clients/presentation/screens/client_items_stats_screen.dart';
import 'package:bnood/features/clients/presentation/screens/movements_list_screen.dart';
import 'package:bnood/features/home/presentation/screens/home_screen.dart';
import 'package:bnood/features/statements/presentation/screens/client_statement_screen.dart';
import 'package:bnood/features/vouchers/presentation/screens/voucher_screen.dart';
import 'package:bnood/features/providers/presentation/screens/provider_detail_screen.dart';
import 'app_shell_directory_body.dart';
import 'auth_router_refresh.dart';
import 'app_splash_session.dart';
import 'app_startup_splash.dart';
import 'app_shell_online_tabs.dart';
import 'app_shell_tab_gate.dart';
import 'shell_scaffold.dart';
import '../core/services/analytics/providers/analytics_providers.dart';
import '../core/services/analytics/routing/analytics_route_observer.dart';
import '../core/services/config/navigation/root_navigator_key.dart';
import '../core/services/error_reporting/sentry_navigation_observers.dart';
import '../core/ui/widgets/toast/shell_dock_presence.dart';

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

  if (isAppGateLocation(loc)) return null;
  if (isPublicContentPageLocation(loc)) return null;

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
    if (needsProfile &&
        loc != AuthPaths.completeProfile &&
        loc != AuthPaths.changePassword) {
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
    if (isAuthFlowLocation(loc) &&
        loc != AuthPaths.changePassword &&
        loc != AuthPaths.completeProfile) {
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
  final screenViewTracker = ref.watch(analyticsScreenViewTrackerProvider);
  // Each shell branch has its own Navigator; an observer instance can attach to only one.
  return GoRouter(
    debugLogDiagnostics: true,
    // AppToaster resolves layout/margins from this key; it must be the real root navigator.
    navigatorKey: rootNavigatorKey,
    observers: [
      BotToastNavigatorObserver(),
      ShellDockPresence.createObserver(),
      ...AnalyticsRouteObservers.forRoot(screenViewTracker),
      ...sentryNavigationObservers(),
    ],
    refreshListenable: refresh,
    initialLocation: AppSplashSession.completed
        ? AuthPaths.login
        : AppStartupSplashPage.path,
    redirect: (_, state) => _authRedirect(ref, state),
    routes: [
      GoRoute(
        path: AppStartupSplashPage.path,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AppStartupSplashPage(),
        ),
      ),
      GoRoute(
        path: AppGatePaths.maintenance,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AppMaintenanceScreen(),
        ),
      ),
      GoRoute(
        path: AppGatePaths.forceUpdate,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AppForceUpdateScreen(),
        ),
      ),
      GoRoute(
        path: AppGatePaths.optionalUpdate,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AppOptionalUpdateScreen(),
        ),
      ),
      GoRoute(
        path: '/pages/:slug',
        builder: (_, state) =>
            ContentPageScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: AuthPaths.bootstrap,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AuthBootstrapScreen(),
        ),
      ),
      GoRoute(
        path: AuthPaths.login,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AuthPaths.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: AuthPaths.registerVerify,
        builder: (_, _) => const RegisterVerifyScreen(),
      ),
      GoRoute(
        path: AuthPaths.completeProfile,
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const CompleteProfileScreen(),
        ),
      ),
      GoRoute(
        path: AuthPaths.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AuthPaths.forgotVerify,
        builder: (_, _) => const ForgotVerifyScreen(),
      ),
      GoRoute(
        path: AuthPaths.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AuthPaths.changePassword,
        builder: (_, _) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: AuthPaths.remote,
        builder: (_, _) => const RemoteWorkspaceScreen(),
      ),
      GoRoute(
        path: AuthPaths.profile,
        builder: (_, _) => const UserProfileScreen(),
      ),
      GoRoute(
        path: AuthPaths.settings,
        redirect: (_, _) => AuthPaths.more,
      ),
      GoRoute(
        path: NotificationsInboxPlaceholderScreen.path,
        builder: (_, _) => const NotificationsInboxPlaceholderScreen(),
      ),
      GoRoute(
        path: AuthPaths.preferences,
        builder: (_, _) => const AppPreferencesScreen(),
      ),
      GoRoute(
        path: AuthPaths.notifications,
        builder: (_, _) => const NotificationSettingsScreen(),
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
            observers: AnalyticsRouteObservers.forShellBranch(
              screenViewTracker,
            ),
            routes: [
              GoRoute(
                path: _localHome,
                builder: (_, _) => const AppShellTabGate(
                  tab: AppShellTabId.home,
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: AnalyticsRouteObservers.forShellBranch(
              screenViewTracker,
            ),
            routes: [
              GoRoute(
                path: '/projects',
                builder: (_, _) => const AppShellTabGate(
                  tab: AppShellTabId.projects,
                  child: ProjectsListScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: AnalyticsRouteObservers.forShellBranch(
              screenViewTracker,
            ),
            routes: [
              GoRoute(
                path: '/directory',
                builder: (_, state) {
                  final tab = state.uri.queryParameters['tab'];
                  return AppShellTabGate(
                    tab: AppShellTabId.providers,
                    child: AppShellDirectoryBody(
                      initialTabIndex: tab == 'craftsmen' ? 1 : 0,
                    ),
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            observers: AnalyticsRouteObservers.forShellBranch(
              screenViewTracker,
            ),
            routes: [
              GoRoute(
                path: AuthPaths.more,
                builder: (_, _) => const AppShellTabGate(
                  tab: AppShellTabId.more,
                  child: MoreScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/items',
        builder: (_, _) => const ItemsScreen(),
      ),
      GoRoute(
        path: '/clients',
        builder: (_, _) => const ClientsListScreen(),
      ),
      GoRoute(
        path: '/projects/:projectId',
        builder: (_, state) {
          final clientId = state.uri.queryParameters['clientId'] ?? '';
          return ProjectDetailScreen(
            projectId: state.pathParameters['projectId']!,
            clientId: clientId,
          );
        },
      ),
      GoRoute(
        path: '/clients/:clientId',
        builder: (_, state) =>
            ClientDetailScreen(clientId: state.pathParameters['clientId']!),
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
        builder: (_, state) => ClientCraftsmenListScreen(
          clientId: state.pathParameters['clientId']!,
        ),
      ),
      GoRoute(
        path: '/clients/:clientId/suppliers',
        builder: (_, state) => ClientSuppliersListScreen(
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
        path: '/providers/:providerId',
        builder: (_, state) => ProviderDetailScreen(
          providerId: state.pathParameters['providerId']!,
        ),
      ),
      GoRoute(
        path: '/suppliers/:supplierId',
        redirect: (_, state) =>
            '/providers/${state.pathParameters['supplierId']}',
      ),
      GoRoute(
        path: '/craftsmen/:craftsmanId',
        redirect: (_, state) =>
            '/providers/${state.pathParameters['craftsmanId']}',
      ),
      GoRoute(
        path: VoucherScreen.path,
        builder: (_, _) => const VoucherScreen(),
      ),
    ],
  );
});
