import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class LibroFormScreen extends StatefulWidget {
  const LibroFormScreen({super.key});

  @override
  State<LibroFormScreen> createState() => _LibroFormScreenState();
}

class _LibroFormScreenState extends State<LibroFormScreen> {
  final _isbnController       = TextEditingController();
  final _tituloController     = TextEditingController();
  final _autoresController    = TextEditingController();
  final _editorialController  = TextEditingController();
  final _anioController       = TextEditingController();
  final _ejemplarController   = TextEditingController();

  bool _isLoading = false;
  String? _mensaje;
  bool _exito = false;

  Future<void> _registrar() async {
    final isbn     = _isbnController.text.trim();
    final titulo   = _tituloController.text.trim();
    final autores  = _autoresController.text.trim();
    final editorial = _editorialController.text.trim();
    final anio     = int.tryParse(_anioController.text.trim());
    final ejemplar = int.tryParse(_ejemplarController.text.trim());

    if (isbn.isEmpty || titulo.isEmpty || autores.isEmpty ||
        editorial.isEmpty || anio == null || ejemplar == null) {
      setState(() { _mensaje = 'Todos los campos son obligatorios y año/ejemplar deben ser números.'; _exito = false; });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conn = await DBConnection.getConnection();
      await conn.query(
        'INSERT INTO libro (isbn, titulo, autores, editorial, anio_publicacion, num_ejemplar) '
            'VALUES (@i, @t, @a, @e, @an, @ej)',
        substitutionValues: {
          'i':  isbn,
          't':  titulo,
          'a':  autores,
          'e':  editorial,
          'an': anio,
          'ej': ejemplar,
        },
      );
      setState(() { _isLoading = false; _exito = true; _mensaje = 'Libro registrado correctamente.'; });
      _limpiar();
    } catch (e) {
      setState(() { _isLoading = false; _exito = false; _mensaje = e.toString(); });
    }
  }

  void _limpiar() {
    _isbnController.clear();
    _tituloController.clear();
    _autoresController.clear();
    _editorialController.clear();
    _anioController.clear();
    _ejemplarController.clear();
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _tituloController.dispose();
    _autoresController.dispose();
    _editorialController.dispose();
    _anioController.dispose();
    _ejemplarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Registrar Libro',
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
                const Text('Datos del libro',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0D2347))),
                const SizedBox(height: 24),
                _campo('ISBN', _isbnController, hint: 'Ej. 978-84-7829-085-7'),
                _campo('Título', _tituloController, hint: 'Ej. Fundamentos de Sistemas de Bases de Datos'),
                _campo('Autores', _autoresController, hint: 'Ej. Ramez Elmasri y Shamkant B. Navathe'),
                _campo('Editorial', _editorialController, hint: 'Ej. Pearson'),
                _campo('Año de publicación', _anioController, hint: 'Ej. 2007', teclado: TextInputType.number),
                _campo('Número de ejemplar', _ejemplarController, hint: 'Ej. 1', teclado: TextInputType.number),
                const SizedBox(height: 8),
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