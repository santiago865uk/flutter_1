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

