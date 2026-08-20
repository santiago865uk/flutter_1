import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/state_placeholders.dart';
import '../../data/models/book_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/book_service.dart';
import '../../data/services/category_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_activity_provider.dart';

/// Pantalla de detalle de un libro: muestra portada, título, autor,
/// categoría y descripción completa, además de accesos directos para
/// leerlo dentro de la app o marcarlo como favorito.
class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  final CategoryService _categoryService = CategoryService();

  BookModel? _book;
  CategoryModel? _category;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final book = await _bookService.fetchById(widget.bookId);
      CategoryModel? category;
      try {
        final categories = await _categoryService.fetchAll();
        for (final element in categories) {
          if (element.id == book.categoryId) {
            category = element;
            break;
          }
        }
      } catch (_) {
        // La categoría es informativa; si falla, seguimos mostrando el libro.
      }
      if (!mounted) return;
      setState(() {
        _book = book;
        _category = category;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No fue posible cargar este libro.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: AppLoadingIndicator(message: 'Cargando libro...'),
      );
    }
    if (_errorMessage != null || _book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          message: _errorMessage ?? 'Libro no encontrado.',
          onRetry: _loadBook,
        ),
      );
    }

    final book = _book!;
    final auth = context.watch<AuthProvider>();
    final activity = context.watch<ReadingActivityProvider>();
    final isFavorite = activity.isFavorite(book.id);
    final isWideScreen = MediaQuery.sizeOf(context).width > 700;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : null,
            ),
            onPressed: () {
              final userId = auth.userProfile?.id;
              if (userId == null) return;
              context
                  .read<ReadingActivityProvider>()
                  .toggleFavorite(userId: userId, book: book);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: isWideScreen ? 640 : double.infinity),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 260,
                      width: 190,
                      child: CachedNetworkImage(
                        imageUrl: book.coverUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.lightSurfaceVariant,
                          child: const Icon(Icons.menu_book_rounded, size: 48),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).scale(
                        begin: const Offset(0.94, 0.94),
                        end: const Offset(1, 1),
                      ),
                  const SizedBox(height: 20),
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'por ${book.author}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_category != null)
                    Chip(
                      label: Text(_category!.name),
                      backgroundColor:
                          AppColors.accentPurple.withOpacity(0.15),
                      side: BorderSide.none,
                    ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Sobre este libro',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description.isEmpty
                        ? 'Este libro todavía no tiene una descripción.'
                        : book.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Leer ahora',
                    icon: Icons.menu_book_rounded,
                    onPressed: () =>
                        context.push(AppRoutes.readerPath(book.id)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
