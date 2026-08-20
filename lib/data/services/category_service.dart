import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/category_model.dart';
import 'supabase_client_service.dart';

/// Servicio de acceso a datos para la tabla `categories`.
///
/// Se usa tanto en la app de lectura (para mostrar categorías) como en
/// el panel de administrador (para crear, editar y eliminar).
class CategoryService {
  final SupabaseClient _client = SupabaseClientService.client;

  Future<List<CategoryModel>> fetchAll() async {
    try {
      final data = await _client
          .from(AppConstants.tableCategories)
          .select()
          .order('name');
      return (data as List)
          .map((row) => CategoryModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException('No fue posible cargar las categorías: $e');
    }
  }

  Future<CategoryModel> create(CategoryModel category) async {
    try {
      final data = await _client
          .from(AppConstants.tableCategories)
          .insert({
            'name': category.name,
            'icon_name': category.iconName,
            'color_hex': category.colorHex,
          })
          .select()
          .single();
      return CategoryModel.fromJson(data);
    } catch (e) {
      throw AppException('No fue posible crear la categoría: $e');
    }
  }

  Future<void> update(CategoryModel category) async {
    try {
      await _client
          .from(AppConstants.tableCategories)
          .update(category.toJson())
          .eq('id', category.id);
    } catch (e) {
      throw AppException('No fue posible actualizar la categoría: $e');
    }
  }

  Future<void> delete(String categoryId) async {
    try {
      await _client
          .from(AppConstants.tableCategories)
          .delete()
          .eq('id', categoryId);
    } catch (e) {
      throw AppException('No fue posible eliminar la categoría: $e');
    }
  }
}
