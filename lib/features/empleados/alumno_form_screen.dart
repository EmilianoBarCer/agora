import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class AlumnoFormScreen extends StatefulWidget {
  const AlumnoFormScreen({super.key});

  @override
  State<AlumnoFormScreen> createState() => _AlumnoFormScreenState();
}

class _AlumnoFormScreenState extends State<AlumnoFormScreen> {
  final _codigoController    = TextEditingController();
  final _nombreController    = TextEditingController();
  final _carreraController   = TextEditingController();
  final _correoController    = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController  = TextEditingController();
  final _fechaController     = TextEditingController();

  String _sexo = 'M';
  bool _isLoading = false;
  String? _mensaje;
  bool _exito = false;

  Future<void> _registrar() async {
    final codigo    = _codigoController.text.trim();
    final nombre    = _nombreController.text.trim();
    final carrera   = _carreraController.text.trim();
    final correo    = _correoController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono  = _telefonoController.text.trim();
    final fecha     = _fechaController.text.trim();

    if (codigo.isEmpty || nombre.isEmpty || carrera.isEmpty ||
        correo.isEmpty || direccion.isEmpty || telefono.isEmpty || fecha.isEmpty) {
      setState(() { _mensaje = 'Todos los campos son obligatorios.'; _exito = false; });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conn = await DBConnection.getConnection();
      await conn.query(
        'INSERT INTO alumno (codigo, nombre, carrera, correo, direccion, telefono, sexo, fecha_nacimiento) '
            'VALUES (@co, @n, @ca, @cr, @d, @t, @s, @f)',
        substitutionValues: {
          'co': codigo,
          'n':  nombre,
          'ca': carrera,
          'cr': correo,
          'd':  direccion,
          't':  telefono,
          's':  _sexo,
          'f':  fecha,
        },
      );
      setState(() { _isLoading = false; _exito = true; _mensaje = 'Alumno registrado correctamente.'; });
      _limpiar();
    } catch (e) {
      setState(() { _isLoading = false; _exito = false; _mensaje = e.toString(); });
    }
  }

  void _limpiar() {
    _codigoController.clear();
    _nombreController.clear();
    _carreraController.clear();
    _correoController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    _fechaController.clear();
    setState(() => _sexo = 'M');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _carreraController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Registrar Alumno',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datos del alumno',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0D2347))),
                const SizedBox(height: 24),
                _campo('Código', _codigoController, hint: 'Ej. 2218813479'),
                _campo('Nombre completo', _nombreController, hint: 'Ej. AGUILA CONTRERAS DIEGO'),
                _campo('Carrera', _carreraController, hint: 'Ej. ICOM'),
                _campo('Correo', _correoController, hint: 'Ej. diego@alumnos.udg.mx', teclado: TextInputType.emailAddress),
                _campo('Dirección', _direccionController, hint: 'Ej. Toledo 2588'),
                _campo('Teléfono', _telefonoController, hint: 'Ej. 3355778899', teclado: TextInputType.phone),
                _campo('Fecha de nacimiento', _fechaController, hint: 'YYYY-MM-DD'),
                const Text('Sexo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3C3C4C))),
                const SizedBox(height: 8),
                Row(
                  children: ['M', 'F'].map((s) => Expanded(
                    child: RadioListTile<String>(
                      title: Text(s == 'M' ? 'Masculino' : 'Femenino'),
                      value: s,
                      groupValue: _sexo,
                      activeColor: const Color(0xFF1A3A6B),
                      onChanged: (v) => setState(() => _sexo = v!),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                if (_mensaje != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _exito ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _exito ? Icons.check_circle_outline : Icons.info_outline_rounded,
                          color: _exito ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(child: Text(_mensaje!,
                            style: TextStyle(
                                color: _exito ? const Color(0xFF2E7D32) : const Color(0xFFE53935),
                                fontSize: 13))),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Registrar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller,
      {String hint = '', TextInputType teclado = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3C3C4C))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: teclado,
            style: const TextStyle(fontSize: 15, color: Color(0xFF0D2347), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFAEAEB2)),
              filled: true,
              fillColor: const Color(0xFFF2F4F8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}