import 'package:equatable/equatable.dart';

/// Representa una categoría infantil (tabla `categories` en Supabase).
///
/// Ejemplos: Aventura, Fantasía, Animales, Ciencia, Valores, Cuentos
/// clásicos, etc.
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? iconName; // Nombre lógico de icono (ver CategoryIcons)
  final String? colorHex; // Color asignado en formato "#RRGGBB"

  const CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
    };
  }

  CategoryModel copyWith({
    String? name,
    String? iconName,
    String? colorHex,
  }) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [id, name, iconName, colorHex];
}
