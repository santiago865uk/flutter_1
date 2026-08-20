import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/state_placeholders.dart';
import '../../data/models/book_model.dart';
import '../../data/services/book_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_activity_provider.dart';

/// Pantalla de lectura dentro de la app.
///
/// Decide qué visor usar según [BookModel.fileType]:
/// - PDF: `syncfusion_flutter_pdfviewer`, que además reporta el número
///   de página actual para poder guardar el progreso.
/// - EPUB: `epub_view`, que reporta el capítulo/posición actual.
///
/// En ambos casos, el progreso se guarda automáticamente en la tabla
/// `reading_history` cada vez que el usuario cambia de página, y
/// también al salir de la pantalla.
class ReaderScreen extends StatefulWidget {
  final String bookId;
  const ReaderScreen({super.key, required this.bookId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final BookService _bookService = BookService();
  final PdfViewerController _pdfController = PdfViewerController();
  EpubController? _epubController;

  BookModel? _book;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;

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

      if (book.fileType == BookFileType.epub) {
        _epubController = EpubController(
          document: EpubDocument.openUrl(book.fileUrl),
        );
      }

      if (!mounted) return;
      setState(() {
        _book = book;
        _currentPage = context
            .read<ReadingActivityProvider>()
            .lastPageFor(book.id);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No fue posible abrir este libro para lectura.';
        _isLoading = false;
      });
    }
  }

  void _saveProgress(int page) {
    final userId = context.read<AuthProvider>().userProfile?.id;
    final book = _book;
    if (userId == null || book == null) return;
    context.read<ReadingActivityProvider>().saveReadingProgress(
          userId: userId,
          bookId: book.id,
          lastPageRead: page,
        );
  }

  @override
  void dispose() {
    _epubController?.dispose();
    if (_currentPage > 0) {
      _saveProgress(_currentPage);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: AppLoadingIndicator(message: 'Abriendo libro...'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, overflow: TextOverflow.ellipsis),
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: book.fileType == BookFileType.pdf
          ? _buildPdfViewer(book)
          : _buildEpubViewer(),
    );
  }

  Widget _buildPdfViewer(BookModel book) {
    return SfPdfViewer.network(
      book.fileUrl,
      controller: _pdfController,
      initialScrollOffset: Offset.zero,
      onPageChanged: (details) {
        _currentPage = details.newPageNumber;
        _saveProgress(_currentPage);
      },
      onDocumentLoaded: (details) {
        if (_currentPage > 0 &&
            _currentPage <= details.document.pages.count) {
          _pdfController.jumpToPage(_currentPage);
        }
      },
    );
  }

  Widget _buildEpubViewer() {
    final controller = _epubController;
    if (controller == null) {
      return const AppErrorState(message: 'No fue posible abrir el EPUB.');
    }
    return EpubView(
      controller: controller,
      onChapterChanged: (value) {
        final chapterIndex = value?.chapterNumber ?? 0;
        _currentPage = chapterIndex;
        _saveProgress(_currentPage);
      },
    );
  }
}
