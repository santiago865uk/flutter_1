/// Nombres de ruta centralizados, usados por [AppRouter] y por
/// cualquier llamada a `context.go(...)` o `context.push(...)` en la
/// app, evitando strings sueltos repartidos por las pantallas.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String search = '/search';
  static const String bookDetail = '/book/:id';
  static const String reader = '/book/:id/read';
  static const String favorites = '/favorites';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static const String admin = '/admin';
  static const String adminBooks = '/admin/books';
  static const String adminBookForm = '/admin/books/form';
  static const String adminCategories = '/admin/categories';
  static const String adminUsers = '/admin/users';

  static String bookDetailPath(String id) => '/book/$id';
  static String readerPath(String id) => '/book/$id/read';
}
