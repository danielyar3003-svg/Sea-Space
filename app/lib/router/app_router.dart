import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/setup_required_screen.dart';
import '../features/home/dashboard_screen.dart';
import '../features/placeholder/feature_placeholder_screen.dart';
import '../features/profile/profile_edit_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';
import 'features.dart';

abstract final class Routes {
  static const setup = '/setup';
  static const login = '/login';
  static const home = '/home';
  static const discover = '/discover';
  static const companies = '/companies';
  static const mail = '/mail';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const settings = '/settings';
  static String tool(String id) => '/tools/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (auth == null) return loc == Routes.setup ? null : Routes.setup;
      if (!auth.isSignedIn) return loc == Routes.login ? null : Routes.login;
      if (loc == Routes.login || loc == Routes.setup) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.setup, builder: (_, _) => const SetupRequiredScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.home, builder: (_, _) => const DashboardScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.discover,
                builder: (_, _) => const FeaturePlaceholderScreen(
                  title: 'Discover',
                  icon: Icons.travel_explore_outlined,
                  phase: 3,
                  description:
                      'Find maritime employers, recruitment contacts and vacancies — '
                      'including companies with no advertised openings.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.companies,
                builder: (_, _) => const FeaturePlaceholderScreen(
                  title: 'Companies',
                  icon: Icons.apartment_outlined,
                  phase: 3,
                  description:
                      'Your employer database with fleets, hiring status, '
                      'HR contacts and source links.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.mail,
                builder: (_, _) => const FeaturePlaceholderScreen(
                  title: 'Mail',
                  icon: Icons.mail_outline,
                  phase: 5,
                  description:
                      'Gmail inbox linked to companies and applications. '
                      'Every outgoing e-mail needs your explicit approval.',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, state) => ProfileEditScreen(args: state.extra as ProfileEditArgs?),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: '/tools/:id',
        builder: (_, state) {
          final f = featureById(state.pathParameters['id']!);
          if (f == null) {
            return const FeaturePlaceholderScreen(
              title: 'Not found',
              icon: Icons.help_outline,
              phase: 0,
              description: '',
            );
          }
          return FeaturePlaceholderScreen(
            title: f.title,
            icon: f.icon,
            phase: f.phase,
            description: f.description,
            standalone: true,
          );
        },
      ),
    ],
  );
});
