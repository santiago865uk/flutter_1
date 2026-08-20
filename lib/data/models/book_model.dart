import 'package:equatable/equatable.dart';

/// Formatos de archivo soportados para la lectura dentro de la app.
enum BookFileType { pdf, epub }

BookFileType bookFileTypeFromString(String? value) {
  switch (value) {
    case 'epub':
      return BookFileType.epub;
    case 'pdf':
    default:
      return BookFileType.pdf;
  }
}

String bookFileTypeToString(BookFileType type) {
  return type == BookFileType.epub ? 'epub' : 'pdf';
}

/// Representa un libro almacenado en la tabla `books` de Supabase.
///
/// [coverUrl] y [fileUrl] apuntan a objetos públicos (o firmados) dentro
/// de los buckets de Supabase Storage `book-covers` y `book-files`.
class BookModel extends Equatable {
  final String id;
  final String title;
  final String author;
  final String description;
  final String categoryId;
  final String coverUrl;
  final String fileUrl;
  final BookFileType fileType;
  final bool isFeatured;
  final int totalPages;
  final DateTime createdAt;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.categoryId,
    required this.coverUrl,
    required this.fileUrl,
    required this.fileType,
    required this.createdAt,
    this.isFeatured = false,
    this.totalPages = 0,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? 'Autor desconocido',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String,
      coverUrl: json['cover_url'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      fileType: bookFileTypeFromString(json['file_type'] as String?),
      isFeatured: json['is_featured'] as bool? ?? false,
      totalPages: json['total_pages'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'category_id': categoryId,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'file_type': bookFileTypeToString(fileType),
      'is_featured': isFeatured,
      'total_pages': totalPages,
    };
  }

  BookModel copyWith({
    String? title,
    String? author,
    String? description,
    String? categoryId,
    String? coverUrl,
    String? fileUrl,
    BookFileType? fileType,
    bool? isFeatured,
    int? totalPages,
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      coverUrl: coverUrl ?? this.coverUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      isFeatured: isFeatured ?? this.isFeatured,
      totalPages: totalPages ?? this.totalPages,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        categoryId,
        coverUrl,
        fileUrl,
        fileType,
        isFeatured,
        totalPages,
        createdAt,
      ];
}
