import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class ProfesorFormScreen extends StatefulWidget {
  const ProfesorFormScreen({super.key});

  @override
  State<ProfesorFormScreen> createState() => _ProfesorFormScreenState();
}

class _ProfesorFormScreenState extends State<ProfesorFormScreen> {
  final _codigoController     = TextEditingController();
  final _nombreController     = TextEditingController();
  final _direccionController  = TextEditingController();
  final _telefonoController   = TextEditingController();
  final _fechaController      = TextEditingController();
  final _deptoController      = TextEditingController();
  final _correoController     = TextEditingController();

  String _sexo = 'M';
  bool _isLoading = false;
  String? _mensaje;
  bool _exito = false;

  Future<void> _registrar() async {
    final codigo    = _codigoController.text.trim();
    final nombre    = _nombreController.text.trim();
    final direccion = _direccionController.text.trim();
    final telefono  = _telefonoController.text.trim();
    final fecha     = _fechaController.text.trim();
    final depto     = _deptoController.text.trim();
    final correo    = _correoController.text.trim();

    if (codigo.isEmpty || nombre.isEmpty || direccion.isEmpty ||
        telefono.isEmpty || fecha.isEmpty || depto.isEmpty || correo.isEmpty) {
      setState(() { _mensaje = 'Todos los campos son obligatorios.'; _exito = false; });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conn = await DBConnection.getConnection();
      await conn.query(
        'INSERT INTO profesor (codigo, nombre, direccion, telefono, sexo, fecha_nacimiento, departamento, correo) '
            'VALUES (@co, @n, @d, @t, @s, @f, @de, @cr)',
        substitutionValues: {
          'co': codigo,
          'n':  nombre,
          'd':  direccion,
          't':  telefono,
          's':  _sexo,
          'f':  fecha,
          'de': depto,
          'cr': correo,
        },
      );
      setState(() { _isLoading = false; _exito = true; _mensaje = 'Profesor registrado correctamente.'; });
      _limpiar();
    } catch (e) {
      setState(() { _isLoading = false; _exito = false; _mensaje = e.toString(); });
    }
  }

  void _limpiar() {
    _codigoController.clear();
    _nombreController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    _fechaController.clear();
    _deptoController.clear();
    _correoController.clear();
    setState(() => _sexo = 'M');
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    _deptoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Registrar Profesor',
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
                const Text('Datos del profesor',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0D2347))),
                const SizedBox(height: 24),
                _campo('Código', _codigoController, hint: 'Ej. 2314686'),
                _campo('Nombre completo', _nombreController, hint: 'Ej. MARISCAL LUGO LUIS FELIPE'),
                _campo('Dirección', _direccionController, hint: 'Ej. Av. Revolución 1500'),
                _campo('Teléfono', _telefonoController, hint: 'Ej. 3314517287', teclado: TextInputType.phone),
                _campo('Fecha de nacimiento', _fechaController, hint: 'YYYY-MM-DD'),
                _campo('Departamento', _deptoController, hint: 'Ej. Ciencias Computacionales'),
                _campo('Correo', _correoController, hint: 'Ej. felipe.mariscal@academicos.udg.mx', teclado: TextInputType.emailAddress),
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