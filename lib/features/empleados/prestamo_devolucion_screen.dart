import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/db_connection.dart';

class PrestamoDevolucionScreen extends StatefulWidget {
  const PrestamoDevolucionScreen({super.key});

  @override
  State<PrestamoDevolucionScreen> createState() =>
      _PrestamoDevolucionScreenState();
}

class _PrestamoDevolucionScreenState extends State<PrestamoDevolucionScreen> {
  final _idController    = TextEditingController();
  final _fechaController = TextEditingController();

  bool _isLoading = false;
  String? _mensaje;
  bool _exito = false;

  Future<void> _devolver() async {
    final id    = int.tryParse(_idController.text.trim());
    final fecha = _fechaController.text.trim();

    if (id == null || fecha.isEmpty) {
      setState(() { _mensaje = 'Todos los campos son obligatorios.'; _exito = false; });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final conn = await DBConnection.getConnection();

      final rows = await conn.query(
        'SELECT p.id_prestamo, p.solicitante, p.isbn, p.num_ejemplar, '
            'p.fecha_limite, l.titulo, l.autores, '
            'COALESCE(pr.correo, al.correo) as correo, '
            'COALESCE(pr.nombre, al.nombre) as nombre '
            'FROM prestamo p '
            'LEFT JOIN libro l ON l.isbn = p.isbn AND l.num_ejemplar = p.num_ejemplar '
            'LEFT JOIN profesor pr ON pr.codigo = p.solicitante '
            'LEFT JOIN alumno al ON al.codigo = p.solicitante '
            'WHERE p.id_prestamo = @id AND p.estatus = \'Prestado\'',
        substitutionValues: {'id': id},
      );

      if (rows.isEmpty) {
        setState(() { _isLoading = false; _mensaje = 'Préstamo no encontrado o ya devuelto.'; _exito = false; });
        return;
      }

      final row             = rows.first;
      final fechaLimite     = DateTime.parse(row[4].toString().split(' ')[0]);
      final fechaDevol      = DateTime.parse(fecha);
      final fechaLimiteSolo = DateTime(fechaLimite.year, fechaLimite.month, fechaLimite.day);
      final fechaDevolucionSolo = DateTime(fechaDevol.year, fechaDevol.month, fechaDevol.day);
      final diasRetraso     = fechaDevolucionSolo.difference(fechaLimiteSolo).inDays;
      final titulo          = row[5].toString();
      final autores         = row[6].toString();
      final correo          = row[7].toString();
      final nombre          = row[8].toString();

      // Determinar tipo de solicitante y multa por día
      final esProfesor = await conn.query(
        'SELECT codigo FROM profesor WHERE codigo = @s',
        substitutionValues: {'s': row[1].toString()},
      );
      final multaPorDia = esProfesor.isNotEmpty ? 10.0 : 5.0;
      final multa       = diasRetraso > 0 ? diasRetraso * multaPorDia : 0.0;
      final tipoSolicitante = esProfesor.isNotEmpty ? 'Profesor' : 'Alumno';

      await conn.query(
        'UPDATE prestamo SET fecha_devolucion = @fd, estatus = @es, multa = @m '
            'WHERE id_prestamo = @id',
        substitutionValues: {
          'fd': fecha,
          'es': 'Entregado',
          'm':  multa,
          'id': id,
        },
      );

      if (multa > 0) {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('AGORA - Software de Biblioteca',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('REPORTE DE MULTA', style: pw.TextStyle(fontSize: 16)),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text('Solicitante: $nombre'),
                pw.Text('Tipo: $tipoSolicitante'),
                pw.Text('Libro: $titulo'),
                pw.Text('Autores: $autores'),
                pw.Text('Fecha límite: ${fechaLimite.toIso8601String().split('T')[0]}'),
                pw.Text('Fecha devolución: $fecha'),
                pw.Text('Días de retraso: $diasRetraso'),
                pw.SizedBox(height: 12),
                pw.Text('Multa por día: \$$multaPorDia ($tipoSolicitante)',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text('Nota: profesores pagan \$10.00 por día, alumnos \$5.00 por día.',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Divider(),
                pw.Text('TOTAL A PAGAR: \$$multa',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        );

        final path = '${Directory.systemTemp.path}/multa_prestamo_$id.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        await _enviarCorreo(correo, nombre, multa, path);

        setState(() {
          _isLoading = false;
          _exito = true;
          _mensaje = 'Devolución registrada. Multa: \$$multa. PDF enviado a $correo.';
        });
      } else {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('AGORA - Software de Biblioteca',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('CONFIRMACIÓN DE ENTREGA', style: pw.TextStyle(fontSize: 16)),
                pw.Divider(),
                pw.SizedBox(height: 12),
                pw.Text('Solicitante: $nombre'),
                pw.Text('Tipo: $tipoSolicitante'),
                pw.Text('Libro: $titulo'),
                pw.Text('Autores: $autores'),
                pw.Text('Fecha límite: ${fechaLimite.toIso8601String().split('T')[0]}'),
                pw.Text('Fecha devolución: $fecha'),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.Text('ENTREGA EN TIEMPO Y FORMA. SIN MULTA.',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('Nota: en caso de retraso, profesores pagan \$10.00 por día y alumnos \$5.00 por día.',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
          ),
        );

        final path = '${Directory.systemTemp.path}/confirmacion_prestamo_$id.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());
        await _enviarCorreoConfirmacion(correo, nombre, path);

        setState(() {
          _isLoading = false;
          _exito = true;
          _mensaje = 'Devolución registrada. Sin multa. Confirmación enviada a $correo.';
        });
      }

      _limpiar();
    } catch (e) {
      setState(() { _isLoading = false; _exito = false; _mensaje = e.toString(); });
    }
  }

  Future<void> _enviarCorreo(
      String destinatario, String nombre, double multa, String pdfPath) async {
    const usuario  = 'agorapp.notification@gmail.com';
    const password = 'yvuh lbxu fzjh sdes';

    final smtpServer = gmail(usuario, password);
    final message    = Message()
      ..from    = Address(usuario, 'Agora Biblioteca')
      ..recipients.add(destinatario)
      ..subject = 'Notificación de multa - Biblioteca Agora'
      ..text    = 'Estimado/a $nombre, se ha generado una multa de \$$multa por retraso en la devolución del libro. Adjunto encontrará el detalle.'
      ..attachments.add(FileAttachment(File(pdfPath)));

    await send(message, smtpServer);
  }

  Future<void> _enviarCorreoConfirmacion(
      String destinatario, String nombre, String pdfPath) async {
    const usuario  = 'agorapp.notification@gmail.com';
    const password = 'yvuh lbxu fzjh sdes';

    final smtpServer = gmail(usuario, password);
    final message    = Message()
      ..from    = Address(usuario, 'Agora Biblioteca')
      ..recipients.add(destinatario)
      ..subject = 'Confirmación de entrega - Biblioteca Agora'
      ..text    = 'Estimado/a $nombre, su libro ha sido devuelto en tiempo y forma. Adjunto encontrará su comprobante de entrega.'
      ..attachments.add(FileAttachment(File(pdfPath)));

    await send(message, smtpServer);
  }

  void _limpiar() {
    _idController.clear();
    _fechaController.clear();
  }

  @override
  void dispose() {
    _idController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Devolver Préstamo',
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
                const Text('Registrar Devolución',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0D2347))),
                const SizedBox(height: 8),
                const Text(
                  'Profesores: \$10.00 por día de retraso. Alumnos: \$5.00 por día de retraso.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF8E8EA0)),
                ),
                const SizedBox(height: 24),
                _campo('ID del préstamo', _idController, hint: 'Ej. 1', teclado: TextInputType.number),
                _campo('Fecha de devolución', _fechaController, hint: 'YYYY-MM-DD'),
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
                    onPressed: _isLoading ? null : _devolver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A6B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Text('Registrar devolución',
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