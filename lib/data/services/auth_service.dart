import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_profile_model.dart';
import 'supabase_client_service.dart';

/// Servicio responsable de toda la comunicación con Supabase Auth:
/// registro, inicio de sesión, cierre de sesión, recuperación de
/// contraseña y lectura del perfil asociado al usuario autenticado.
///
/// Esta clase NO mantiene estado de UI; ese trabajo corresponde a
/// [AuthProvider] en la capa `providers`. El servicio solo habla con
/// el backend y traduce sus errores a [AppException].
class AuthService {
  final SupabaseClient _client = SupabaseClientService.client;

  /// Usuario actualmente autenticado (o `null` si no hay sesión activa).
  User? get currentUser => _client.auth.currentUser;

  /// Stream de cambios de sesión, útil para reaccionar a login/logout
  /// en cualquier parte de la app (por ejemplo, para redirigir rutas).
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Registra un nuevo usuario y crea su fila correspondiente en la
  /// tabla `profiles` con rol de lector por defecto.
  Future<UserProfileModel> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      final user = response.user;
      if (user == null) {
        throw const AppException(
          'No fue posible crear la cuenta. Intenta nuevamente.',
        );
      }

      final profile = UserProfileModel(
        id: user.id,
        fullName: fullName,
        email: email,
        role: AppConstants.roleReader,
        createdAt: DateTime.now(),
      );

      await _client
          .from(AppConstants.tableProfiles)
          .insert(profile.toJson());

      return profile;
    } on AuthException catch (e) {
      throw AppException(_translateAuthError(e.message));
    } catch (e) {
      throw AppException('Ocurrió un error al registrar la cuenta: $e');
    }
  }

  /// Inicia sesión con correo y contraseña, devolviendo el perfil
  /// completo del usuario (incluyendo su rol).
  Future<UserProfileModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AppException('Correo o contraseña incorrectos.');
      }

      return fetchCurrentProfile();
    } on AuthException catch (e) {
      throw AppException(_translateAuthError(e.message));
    } catch (e) {
      throw AppException('Ocurrió un error al iniciar sesión: $e');
    }
  }

  /// Envía un correo de recuperación de contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AppException(_translateAuthError(e.message));
    } catch (e) {
      throw AppException(
        'No fue posible enviar el correo de recuperación: $e',
      );
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Obtiene el perfil (tabla `profiles`) del usuario actualmente
  /// autenticado.
  Future<UserProfileModel> fetchCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      throw const AppException('No hay una sesión activa.');
    }

    final data = await _client
        .from(AppConstants.tableProfiles)
        .select()
        .eq('id', user.id)
        .single();

    return UserProfileModel.fromJson(data);
  }

  /// Traduce los mensajes de error de Supabase Auth (en inglés) a
  /// mensajes claros en español para el usuario final.
  String _translateAuthError(String rawMessage) {
    final message = rawMessage.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('user already registered')) {
      return 'Ya existe una cuenta registrada con ese correo.';
    }
    if (message.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (message.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    return rawMessage;
  }
}
