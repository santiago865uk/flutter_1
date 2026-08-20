import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Representa un perfil de usuario almacenado en la tabla `profiles`
/// de Supabase. Se relaciona 1 a 1 con el usuario autenticado en
/// Supabase Auth mediante el campo [id].
class UserProfileModel extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String role; // 'admin' | 'reader'
  final DateTime createdAt;

  const UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
  });

  /// Indica si el usuario tiene privilegios de administrador.
  bool get isAdmin => role == AppConstants.roleAdmin;

  /// Construye una instancia a partir de un mapa JSON (fila de Supabase).
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Lector sin nombre',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? AppConstants.roleReader,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convierte la instancia a un mapa JSON listo para insertar/actualizar
  /// en Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
    };
  }

  UserProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? role,
  }) {
    return UserProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, fullName, email, avatarUrl, role, createdAt];
}
