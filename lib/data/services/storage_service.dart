import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import 'supabase_client_service.dart';

/// Servicio responsable de subir archivos binarios (portadas, PDFs,
/// EPUBs, avatares) a Supabase Storage y devolver su URL pública.
///
/// Usado principalmente por el panel de administrador al agregar o
/// editar libros, y por la pantalla de perfil al cambiar el avatar.
class StorageService {
  final SupabaseClient _client = SupabaseClientService.client;
  final Uuid _uuid = const Uuid();

  /// Sube la portada de un libro y devuelve su URL pública.
  Future<String> uploadBookCover(File file) {
    return _uploadFile(bucket: AppConstants.bucketCovers, file: file);
  }

  /// Sube el archivo del libro (PDF o EPUB) y devuelve su URL pública.
  Future<String> uploadBookFile(File file) {
    return _uploadFile(bucket: AppConstants.bucketFiles, file: file);
  }

  /// Sube el avatar de un usuario y devuelve su URL pública.
  Future<String> uploadAvatar(File file) {
    return _uploadFile(bucket: AppConstants.bucketAvatars, file: file);
  }

  Future<String> _uploadFile({
    required String bucket,
    required File file,
  }) async {
    try {
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';

      await _client.storage.from(bucket).upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return _client.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      throw AppException('No fue posible subir el archivo: $e');
    }
  }

  /// Elimina un archivo del bucket dado a partir de su nombre.
  Future<void> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    try {
      await _client.storage.from(bucket).remove([fileName]);
    } catch (e) {
      throw AppException('No fue posible eliminar el archivo: $e');
    }
  }
}
