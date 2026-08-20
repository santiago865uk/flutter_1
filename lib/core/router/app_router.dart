import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/welcome_screen.dart';
import '../../screens/book_detail/book_detail_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/main_navigation_shell.dart';
import '../../screens/reader/reader_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../widgets/coming_soon_screen.dart';
import 'app_routes.dart';

/// Construye el [GoRouter] de la aplicación.
///
/// - `redirect` protege las rutas: si no hay sesión activa, cualquier
///   intento de entrar a una ruta del área autenticada redirige a
///   Bienvenida; si ya hay sesión, no se puede volver a Login/Registro.
/// - Las rutas de administrador (`/admin/**`) además exigen que el
///   perfil autenticado tenga `role == 'admin'`.
/// - `refreshListenable` hace que el router reevalúe `redirect`
///   automáticamente cada vez que [AuthProvider] cambia de estado
///   (por ejemplo, justo después de iniciar o cerrar sesión).
class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // -----------------------------------------------------------------
      // Área autenticada con barra de navegación inferior.
      // -----------------------------------------------------------------
      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = _tabIndexForLocation(state.uri.toString());
          return MainNavigationShell(
            currentIndex: currentIndex,
            onTabSelected: (index) =>
                context.go(_tabRoutes[index]),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: AppRoutes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ComingSoonScreen(
              title: 'Mi perfil',
              icon: Icons.person_rounded,
              description: 'La pantalla de perfil llega en la Fase 3.',
            ),
          ),
        ],
      ),

      // Rutas fuera del shell (pantalla completa, sin barra inferior).
      GoRoute(
        path: AppRoutes.bookDetail,
        builder: (context, state) => BookDetailScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.reader,
        builder: (context, state) => ReaderScreen(
          bookId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Configuración',
          icon: Icons.settings_rounded,
          description: 'La pantalla de configuración llega en la Fase 3.',
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Panel de administrador',
          icon: Icons.admin_panel_settings_rounded,
          description: 'El panel de administrador llega en la Fase 4.',
        ),
      ),
    ],
  );

  static const _tabRoutes = [
    AppRoutes.home,
    AppRoutes.search,
    AppRoutes.favorites,
    AppRoutes.history,
    AppRoutes.profile,
  ];

  int _tabIndexForLocation(String location) {
    final index = _tabRoutes.indexWhere((route) => location.startsWith(route));
    return index == -1 ? 0 : index;
  }

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final status = authProvider.status;
    final location = state.uri.toString();

    final isSplash = location == AppRoutes.splash;
    final isAuthRoute = location == AppRoutes.welcome ||
        location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword;
    final isAdminRoute = location.startsWith(AppRoutes.admin);

    // Mientras no se resuelve el estado de sesión, dejamos que el
    // splash haga su trabajo sin redirigir.
    if (status == AuthStatus.unknown) {
      return isSplash ? null : null;
    }

    final isAuthenticated = status == AuthStatus.authenticated;

    if (!isAuthenticated && !isAuthRoute && !isSplash) {
      return AppRoutes.welcome;
    }

    if (isAuthenticated && isAuthRoute) {
      return AppRoutes.home;
    }

    if (isAdminRoute && !(authProvider.isAdmin)) {
      return AppRoutes.home;
    }

    return null;
  }
}
