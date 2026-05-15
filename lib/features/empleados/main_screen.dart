import 'package:flutter/material.dart';
import 'empleado_form_screen.dart';
import 'empleado_list_screen.dart';
import 'alumno_form_screen.dart';
import 'alumno_list_screen.dart';
import 'profesor_form_screen.dart';
import 'profesor_list_screen.dart';
import 'libro_form_screen.dart';
import 'libro_list_screen.dart';
import 'package:agora/features/auth/login_screen.dart';

class MainScreen extends StatelessWidget {
  final String username;
  const MainScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset('assets/images/logoAgora.png', height: 36),
            const SizedBox(width: 12),
            const Text(
              'Agora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: Color(0xFFFFC107), size: 20),
                const SizedBox(width: 8),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFFFC107), size: 18),
                  label: const Text('Salir',
                      style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1A3A6B),
            child: Row(
              children: [
                _MenuButton(
                  label: 'EMPLEADOS',
                  items: const ['Registrar', 'Consulta individual', 'Consulta general', 'Cambiar', 'Eliminar'],
                  onSelected: (item) {
                    switch (item) {
                      case 'Registrar':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmpleadoFormScreen()));
                        break;
                      case 'Consulta general':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmpleadoListScreen()));
                        break;
                    }
                  },
                ),
                _MenuButton(
                  label: 'ALUMNOS',
                  items: const ['Registrar', 'Consulta individual', 'Consulta general', 'Cambiar', 'Eliminar'],
                  onSelected: (item) {
                    switch (item) {
                      case 'Registrar':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlumnoFormScreen()));
                        break;
                      case 'Consulta general':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AlumnoListScreen()));
                        break;
                    }
                  },
                ),
                _MenuButton(
                  label: 'PROFESORES',
                  items: const ['Registrar', 'Consulta individual', 'Consulta general', 'Cambiar', 'Eliminar'],
                  onSelected: (item) {
                    switch (item) {
                      case 'Registrar':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfesorFormScreen()));
                        break;
                      case 'Consulta general':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfesorListScreen()));
                        break;
                    }
                  },
                ),
                _MenuButton(
                  label: 'LIBROS',
                  items: const ['Registrar', 'Consulta individual', 'Consulta general', 'Cambiar', 'Eliminar'],
                  onSelected: (item) {
                    switch (item) {
                      case 'Registrar':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LibroFormScreen()));
                        break;
                      case 'Consulta general':
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LibroListScreen()));
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logoAgora.png', height: 180),
                  const SizedBox(height: 24),
                  const Text(
                    'Software de Biblioteca',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D2347),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usuario activo: $username',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8EA0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _MenuButton({
    required this.label,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: Colors.white,
      offset: const Offset(0, 40),
      itemBuilder: (_) => items
          .map((item) => PopupMenuItem(
        value: item,
        child: Text(
          item,
          style: const TextStyle(
            color: Color(0xFF0D2347),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}