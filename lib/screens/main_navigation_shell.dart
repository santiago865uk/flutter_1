import 'package:flutter/material.dart';
import '../core/router/app_routes.dart';

/// Contenedor de navegación principal para el área autenticada de
/// lector: muestra una [BottomNavigationBar] fija con acceso directo
/// a Inicio, Buscar, Favoritos, Historial y Perfil.
///
/// Recibe [navigationShell] desde `go_router` (StatefulShellRoute),
/// lo que permite que cada pestaña conserve su propio historial de
/// navegación de forma independiente.
class MainNavigationShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MainNavigationShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const _tabs = [
    _NavTab(icon: Icons.home_rounded, label: 'Inicio', route: AppRoutes.home),
    _NavTab(
        icon: Icons.search_rounded, label: 'Buscar', route: AppRoutes.search),
    _NavTab(
        icon: Icons.favorite_rounded,
        label: 'Favoritos',
        route: AppRoutes.favorites),
    _NavTab(
        icon: Icons.history_rounded,
        label: 'Historial',
        route: AppRoutes.history),
    _NavTab(
        icon: Icons.person_rounded,
        label: 'Perfil',
        route: AppRoutes.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        items: _tabs
            .map(
              (tab) => BottomNavigationBarItem(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  final String route;
  const _NavTab({required this.icon, required this.label, required this.route});
}
