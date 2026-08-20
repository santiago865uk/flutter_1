import 'package:supabase_flutter/supabase_flutter.dart';

/// Encapsula la inicialización y el acceso al cliente de Supabase.
///
/// IMPORTANTE: reemplaza [supabaseUrl] y [supabaseAnonKey] por los
/// valores reales de tu proyecto de Supabase antes de compilar
/// (Project Settings → API en el panel de Supabase). Nunca subas la
/// `service_role key` a este archivo: la app móvil solo debe usar la
/// clave pública `anon`, protegida por las políticas RLS del backend.
class SupabaseClientService {
  SupabaseClientService._();

  static const String supabaseUrl = 'https://pbkbqggeaquncsmuykec.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBia2JxZ2dlYXF1bmNzbXV5a2VjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE5NzQ0MjUsImV4cCI6MjA5NzU1MDQyNX0.iD2ln_FhAlRFRw4ReLe_hwj6v2LRFEvm6tXPSTqmWCg';

  /// Debe llamarse una única vez, antes de `runApp()`, típicamente en
  /// `main.dart`.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Acceso directo al cliente ya inicializado, usado por el resto de
  /// los servicios de la capa `data`.
  static SupabaseClient get client => Supabase.instance.client;
}
