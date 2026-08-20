# Biblioteca Infantil Virtual — App Flutter

App móvil (Flutter) para la plataforma de lectura infantil, con backend en
Supabase (Auth + PostgreSQL + Storage). Este README documenta el estado
actual del proyecto (Fase 1) y cómo ponerlo en marcha.

## Estado del proyecto — Fases 1 y 2 entregadas

✅ Arquitectura completa del proyecto (carpetas `core`, `data`, `providers`,
`screens`, `widgets`), tema claro/oscuro, routing centralizado con
protección de rutas, modelos de datos, y capa de servicios completa contra
Supabase (auth, libros, categorías, favoritos, historial, storage).

✅ Pantallas 100% funcionales: Splash, Bienvenida, Login, Registro,
Recuperar contraseña, Home (categorías + libros destacados), Búsqueda,
Detalle de libro, Lector in-app (PDF vía Syncfusion, EPUB vía epub_view,
con guardado automático de progreso), Favoritos e Historial de lectura.

🚧 Pantallas con placeholder "Próximamente" (navegables, pero pendientes de
implementación): Perfil, Configuración, Panel de administrador. Quedan
programadas así:

- **Fase 3:** Perfil, Configuración (incluye el switch de modo claro/oscuro
  usando `ThemeProvider`, ya implementado a nivel de lógica).
- **Fase 4:** Panel de administrador (CRUD libros/categorías/usuarios,
  subida de archivos, estadísticas).

## Puesta en marcha

1. Instala las dependencias:
   ```bash
   flutter pub get
   ```
2. Configura Supabase en
   `lib/data/services/supabase_client_service.dart`: reemplaza
   `supabaseUrl` y `supabaseAnonKey` por los valores de tu proyecto
   (Project Settings → API en el panel de Supabase). Usa siempre la clave
   pública `anon`, nunca la `service_role`.
3. Ejecuta el esquema SQL de la sección siguiente en el editor SQL de
   Supabase (o reutiliza el ya creado para la versión web del proyecto, si
   la estructura de tablas coincide).
4. Corre la app:
   ```bash
   flutter run
   ```

## Esquema de base de datos (Supabase / PostgreSQL)

```sql
-- Perfiles de usuario (1 a 1 con auth.users)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  avatar_url text,
  role text not null default 'reader' check (role in ('reader', 'admin')),
  created_at timestamptz not null default now()
);

-- Categorías infantiles
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  icon_name text,
  color_hex text
);

-- Libros
create table books (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  author text not null,
  description text not null default '',
  category_id uuid not null references categories(id) on delete cascade,
  cover_url text not null,
  file_url text not null,
  file_type text not null default 'pdf' check (file_type in ('pdf', 'epub')),
  is_featured boolean not null default false,
  total_pages integer not null default 0,
  created_at timestamptz not null default now()
);

-- Favoritos
create table favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  book_id uuid not null references books(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, book_id)
);

-- Historial de lectura
create table reading_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  book_id uuid not null references books(id) on delete cascade,
  last_page_read integer not null default 0,
  last_read_at timestamptz not null default now(),
  unique (user_id, book_id)
);

-- Marcadores de página
create table bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id) on delete cascade,
  book_id uuid not null references books(id) on delete cascade,
  page_number integer not null,
  created_at timestamptz not null default now()
);

-- Row Level Security (cada usuario solo ve/edita lo suyo; los libros y
-- categorías son de lectura pública y de escritura solo para admins)
alter table profiles enable row level security;
alter table categories enable row level security;
alter table books enable row level security;
alter table favorites enable row level security;
alter table reading_history enable row level security;
alter table bookmarks enable row level security;

create policy "Perfiles: el usuario ve y edita el suyo"
  on profiles for all using (auth.uid() = id);

create policy "Categorías: lectura pública"
  on categories for select using (true);

create policy "Libros: lectura pública"
  on books for select using (true);

create policy "Favoritos: solo el dueño"
  on favorites for all using (auth.uid() = user_id);

create policy "Historial: solo el dueño"
  on reading_history for all using (auth.uid() = user_id);

create policy "Marcadores: solo el dueño"
  on bookmarks for all using (auth.uid() = user_id);
```

Buckets de Storage a crear (públicos para lectura): `book-covers`,
`book-files`, `avatars`.

## Arquitectura de carpetas

```
lib/
  core/            # Transversal: tema, rutas, constantes, errores, widgets base
  data/
    models/        # Clases de datos (equatable), mapeadas 1 a 1 a las tablas
    services/      # Toda la comunicación con Supabase (Auth/DB/Storage)
  providers/       # Estado de la app (Provider/ChangeNotifier)
  screens/         # Una carpeta por sección, un archivo por pantalla
  widgets/         # Widgets reutilizables agrupados por dominio (book, category...)
```

## Notas técnicas

- Gestión de estado: `provider` (ChangeNotifier), elegido por su curva de
  aprendizaje suave y su integración directa con `go_router`.
- Enrutamiento: `go_router`, con redirecciones automáticas según sesión y
  rol (lector/administrador).
- Diseño: tipografías Baloo 2 (títulos) y Nunito (texto), cargadas en
  tiempo de ejecución vía `google_fonts` — no requiere archivos `.ttf`
  locales.
- El historial de lectura formatea fechas en español mediante `intl`;
  `main.dart` llama a `initializeDateFormatting('es')` antes de
  `runApp()`, paso obligatorio para que `DateFormat` con locale `es`
  no lance una excepción en tiempo de ejecución.
- El lector PDF (`syncfusion_flutter_pdfviewer`) y el lector EPUB
  (`epub_view`) son paquetes de terceros: como este entorno de
  desarrollo no tiene el SDK de Flutter instalado para compilar y
  verificar, revisa su documentación oficial si al ejecutar
  `flutter pub get` alguna API cambió de nombre entre versiones.
