import 'package:equatable/equatable.dart';
import 'book_model.dart';

/// Representa una fila de la tabla `favorites`: la relación entre un
/// usuario y un libro marcado como favorito.
class FavoriteModel extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final DateTime createdAt;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, bookId, createdAt];
}

/// Combina un [ReadingHistoryModel] con el [BookModel] correspondiente,
/// listo para mostrarse directamente en la pantalla de Historial.
class ReadingHistoryEntry {
  final ReadingHistoryModel history;
  final BookModel book;

  const ReadingHistoryEntry({required this.history, required this.book});
}

/// Representa una fila de la tabla `reading_history`: el registro de
/// que un usuario leyó (o continúa leyendo) un libro, junto con su
/// progreso de lectura en páginas.
class ReadingHistoryModel extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final int lastPageRead;
  final DateTime lastReadAt;

  const ReadingHistoryModel({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.lastPageRead,
    required this.lastReadAt,
  });

  factory ReadingHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      lastPageRead: json['last_page_read'] as int? ?? 0,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'book_id': bookId,
      'last_page_read': lastPageRead,
      'last_read_at': lastReadAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, bookId, lastPageRead, lastReadAt];
}
