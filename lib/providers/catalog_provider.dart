import 'package:flutter/foundation.dart';
import '../core/errors/app_exception.dart';
import '../data/models/book_model.dart';
import '../data/models/category_model.dart';
import '../data/services/book_service.dart';
import '../data/services/category_service.dart';

/// Provider que expone el catálogo de la biblioteca: categorías y
/// libros destacados para la pantalla principal, y resultados de
/// búsqueda para la pantalla de búsqueda.
///
/// Centraliza aquí la carga inicial evita que cada pantalla dispare
/// sus propias peticiones duplicadas al abrir la app.
class CatalogProvider extends ChangeNotifier {
  final BookService _bookService;
  final CategoryService _categoryService;

  CatalogProvider({BookService? bookService, CategoryService? categoryService})
      : _bookService = bookService ?? BookService(),
        _categoryService = categoryService ?? CategoryService();

  List<BookModel> _featuredBooks = [];
  List<CategoryModel> _categories = [];
  List<BookModel> _searchResults = [];

  bool _isLoadingHome = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<BookModel> get featuredBooks => _featuredBooks;
  List<CategoryModel> get categories => _categories;
  List<BookModel> get searchResults => _searchResults;
  bool get isLoadingHome => _isLoadingHome;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  /// Carga en paralelo los libros destacados y las categorías para la
  /// pantalla de inicio.
  Future<void> loadHomeData() async {
    _isLoadingHome = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _bookService.fetchFeatured(),
        _categoryService.fetchAll(),
      ]);
      _featuredBooks = results[0] as List<BookModel>;
      _categories = results[1] as List<CategoryModel>;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'No fue posible cargar el contenido de inicio.';
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<List<BookModel>> loadBooksByCategory(String categoryId) {
    return _bookService.fetchByCategory(categoryId);
  }

  /// Ejecuta una búsqueda de libros por título o autor.
  Future<void> search(String query) async {
    _isSearching = true;
    notifyListeners();
    try {
      _searchResults = await _bookService.search(query);
    } on AppException catch (e) {
      _errorMessage = e.message;
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
