import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/book_model.dart';
import 'supabase_client_service.dart';

/// Servicio de acceso a datos para la tabla `books`.
///
/// Reúne todas las consultas relacionadas con libros: catálogo
/// completo, destacados, búsqueda por texto, filtrado por categoría y
/// las operaciones de creación/edición/eliminación usadas por el
/// panel de administrador.
class BookService {
  final SupabaseClient _client = SupabaseClientService.client;

  Future<List<BookModel>> fetchAll() async {
    try {
      final data = await _client
          .from(AppConstants.tableBooks)
          .select()
          .order('created_at', ascending: false);
      return _mapList(data);
    } catch (e) {
      throw AppException('No fue posible cargar los libros: $e');
    }
  }

  Future<List<BookModel>> fetchFeatured() async {
    try {
      final data = await _client
          .from(AppConstants.tableBooks)
          .select()
          .eq('is_featured', true)
          .limit(AppConstants.featuredBooksLimit);
      return _mapList(data);
    } catch (e) {
      throw AppException('No fue posible cargar los libros destacados: $e');
    }
  }

  Future<List<BookModel>> fetchByCategory(String categoryId) async {
    try {
      final data = await _client
          .from(AppConstants.tableBooks)
          .select()
          .eq('category_id', categoryId);
      return _mapList(data);
    } catch (e) {
      throw AppException('No fue posible cargar los libros de la categoría: $e');
    }
  }

  /// Busca libros cuyo título o autor contenga [query] (insensible a
  /// mayúsculas), usando el operador `ilike` de PostgreSQL.
  Future<List<BookModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final pattern = '%${query.trim()}%';
      final data = await _client
          .from(AppConstants.tableBooks)
          .select()
          .or('title.ilike.$pattern,author.ilike.$pattern');
      return _mapList(data);
    } catch (e) {
      throw AppException('No fue posible completar la búsqueda: $e');
    }
  }

  Future<BookModel> fetchById(String bookId) async {
    try {
      final data = await _client
          .from(AppConstants.tableBooks)
          .select()
          .eq('id', bookId)
          .single();
      return BookModel.fromJson(data);
    } catch (e) {
      throw AppException('No fue posible cargar el libro: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Operaciones de administrador
  // ---------------------------------------------------------------------

  Future<BookModel> create(BookModel book) async {
    try {
      final payload = book.toJson()..remove('id');
      final data = await _client
          .from(AppConstants.tableBooks)
          .insert(payload)
          .select()
          .single();
      return BookModel.fromJson(data);
    } catch (e) {
      throw AppException('No fue posible agregar el libro: $e');
    }
  }

  Future<void> update(BookModel book) async {
    try {
      await _client
          .from(AppConstants.tableBooks)
          .update(book.toJson())
          .eq('id', book.id);
    } catch (e) {
      throw AppException('No fue posible actualizar el libro: $e');
    }
  }

  Future<void> delete(String bookId) async {
    try {
      await _client.from(AppConstants.tableBooks).delete().eq('id', bookId);
    } catch (e) {
      throw AppException('No fue posible eliminar el libro: $e');
    }
  }

  /// Cantidad total de libros — usado en el panel de estadísticas.
  Future<int> countAll() async {
    try {
      final data = await _client.from(AppConstants.tableBooks).select('id');
      return (data as List).length;
    } catch (e) {
      throw AppException('No fue posible calcular las estadísticas: $e');
    }
  }

  List<BookModel> _mapList(dynamic data) {
    return (data as List)
        .map((row) => BookModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}
