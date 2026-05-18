import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class PrestamoFormScreen extends StatefulWidget {
  const PrestamoFormScreen({super.key});

  @override
  State<PrestamoFormScreen> createState() => _PrestamoFormScreenState();
}

class _PrestamoFormScreenState extends State<PrestamoFormScreen> {
  final _solicitanteController = TextEditingController();
  final _isbnController        = TextEditingController();
  final _ejemplarController    = TextEditingController();
  final _fechaController       = TextEditingController();

  bool _isLoading = false;
  String? _mensaje;
  bool _exito = false;

  Future<void> _registrar() async {
    final solicitante = _solicitanteController.text.trim();
    final isbn        = _isbnController.text.trim();
    final ejemplar    = int.tryParse(_ejemplarController.text.trim());
    final fecha       = _fechaController.text.trim();

    if (solicitante.isEmpty || isbn.isEmpty || ejemplar == null || fecha.isEmpty) {
      setState(() {
        _mensaje = 'Todos los campos son obligatorios.';
        _exito = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conn = await DBConnection.getConnection();
      final fechaPrestamo = DateTime.parse(fecha);
      final fechaLimite   = fechaPrestamo.add(const Duration(days: 7));

      await conn.query(
        'INSERT INTO prestamo (solicitante, isbn, num_ejemplar, fecha_prestamo, fecha_limite, estatus, multa) '
            'VALUES (@s, @i, @ej, @fp, @fl, @es, @m)',
        substitutionValues: {
          's':  solicitante,
          'i':  isbn,
          'ej': ejemplar,
          'fp': fechaPrestamo.toIso8601String().split('T')[0],
          'fl': fechaLimite.toIso8601String().split('T')[0],
          'es': 'Prestado',
          'm':  0,
        },
      );

      setState(() {
        _isLoading = false;
        _exito = true;
        _mensaje = 'Préstamo registrado. Fecha límite: ${fechaLimite.toIso8601String().split('T')[0]}';
      });
      _limpiar();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _exito = false;
        _mensaje = e.toString();
      });
    }
  }

  void _limpiar() {
    _solicitanteController.clear();
    _isbnController.clear();
    _ejemplarController.clear();
    _fechaController.clear();
  }

  @override
  void dispose() {
    _solicitanteController.dispose();
    _isbnController.dispose();
    _ejemplarController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Registrar Préstamo',
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
                const Text('Datos del préstamo',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D2347))),
                const SizedBox(height: 8),
                const Text(
                  'El período de préstamo es de 7 días para todos los usuarios.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8EA0)),
                ),
                const SizedBox(height: 24),
                _campo('Código del solicitante', _solicitanteController,
                    hint: 'Ej. 1234567'),
                _campo('ISBN del libro', _isbnController,
                    hint: 'Ej. 000-00-0000-000-0'),
                _campo('Número de ejemplar', _ejemplarController,
                    hint: 'Ej. 1', teclado: TextInputType.number),
                _campo('Fecha de préstamo', _fechaController,
                    hint: 'YYYY-MM-DD'),
                const SizedBox(height: 8),
                if (_mensaje != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _exito
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _exito
                              ? Icons.check_circle_outline
                              : Icons.info_outline_rounded,
                          color: _exito
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE53935),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(_mensaje!,
                              style: TextStyle(
                                  color: _exito
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFE53935),
                                  fontSize: 13)),
                        ),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white))
                        : const Text('Registrar',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
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
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C3C4C))),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: teclado,
            style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0D2347),
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFAEAEB2)),
              filled: true,
              fillColor: const Color(0xFFF2F4F8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFF1A3A6B), width: 1.8)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}