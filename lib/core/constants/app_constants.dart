/// Constantes generales de la aplicación.
///
/// Centraliza valores fijos (nombres de tablas, buckets de almacenamiento,
/// claves de preferencias locales, etc.) para evitar "magic strings"
/// repetidas por todo el proyecto y facilitar su mantenimiento.
class AppConstants {
  AppConstants._(); // Evita que la clase sea instanciada.

  // ---------------------------------------------------------------------
  // Información general
  // ---------------------------------------------------------------------
  static const String appName = 'Biblioteca Infantil';
  static const String appTagline = 'Un mundo de historias te espera';

  // ---------------------------------------------------------------------
  // Nombres de tablas en Supabase (PostgreSQL)
  // ---------------------------------------------------------------------
  static const String tableProfiles = 'profiles';
  static const String tableCategories = 'categories';
  static const String tableBooks = 'books';
  static const String tableFavorites = 'favorites';
  static const String tableReadingHistory = 'reading_history';
  static const String tableBookmarks = 'bookmarks';

  // ---------------------------------------------------------------------
  // Buckets de Supabase Storage
  // ---------------------------------------------------------------------
  static const String bucketCovers = 'book-covers';
  static const String bucketFiles = 'book-files';
  static const String bucketAvatars = 'avatars';

  // ---------------------------------------------------------------------
  // Roles de usuario (columna `role` en tabla profiles)
  // ---------------------------------------------------------------------
  static const String roleAdmin = 'admin';
  static const String roleReader = 'reader';

  // ---------------------------------------------------------------------
  // Claves de SharedPreferences (persistencia local)
  // ---------------------------------------------------------------------
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefLastSession = 'pref_last_session';

  // ---------------------------------------------------------------------
  // Límites y valores por defecto
  // ---------------------------------------------------------------------
  static const int featuredBooksLimit = 10;
  static const int searchDebounceMillis = 400;
  static const double maxContentWidth = 720; // Límite en tablets/desktop
}
