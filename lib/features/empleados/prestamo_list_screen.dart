import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class PrestamoListScreen extends StatefulWidget {
  const PrestamoListScreen({super.key});

  @override
  State<PrestamoListScreen> createState() => _PrestamoListScreenState();
}

class _PrestamoListScreenState extends State<PrestamoListScreen> {
  late Future<List<List<dynamic>>> _futurePrestamos;

  @override
  void initState() {
    super.initState();
    _futurePrestamos = _cargarPrestamos();
  }

  Future<List<List<dynamic>>> _cargarPrestamos() async {
    final conn = await DBConnection.getConnection();
    final results = await conn.query(
      'SELECT id_prestamo, solicitante, isbn, num_ejemplar, fecha_prestamo, '
          'fecha_limite, fecha_devolucion, estatus, multa '
          'FROM prestamo ORDER BY id_prestamo',
    );
    return results.map((r) => r.toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Consulta de Préstamos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<List<dynamic>>>(
          future: _futurePrestamos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Color(0xFFE53935))));
            }

            final prestamos = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFF0D2347)),
                    headingTextStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Solicitante')),
                      DataColumn(label: Text('ISBN')),
                      DataColumn(label: Text('Ejemplar')),
                      DataColumn(label: Text('Fecha Préstamo')),
                      DataColumn(label: Text('Fecha Límite')),
                      DataColumn(label: Text('Fecha Devolución')),
                      DataColumn(label: Text('Estatus')),
                      DataColumn(label: Text('Multa')),
                    ],
                    rows: prestamos.map((p) => DataRow(cells: [
                      DataCell(Text(p[0].toString())),
                      DataCell(Text(p[1].toString())),
                      DataCell(Text(p[2].toString())),
                      DataCell(Text(p[3].toString())),
                      DataCell(Text(p[4].toString().split(' ')[0])),
                      DataCell(Text(p[5].toString().split(' ')[0])),
                      DataCell(Text(p[6] == null ? '-' : p[6].toString().split(' ')[0])),
                      DataCell(Text(p[7].toString())),
                      DataCell(Text('\$${p[8]}')),
                    ])).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}