import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class LibroListScreen extends StatefulWidget {
  const LibroListScreen({super.key});

  @override
  State<LibroListScreen> createState() => _LibroListScreenState();
}

class _LibroListScreenState extends State<LibroListScreen> {
  late Future<List<List<dynamic>>> _futureLibros;

  @override
  void initState() {
    super.initState();
    _futureLibros = _cargarLibros();
  }

  Future<List<List<dynamic>>> _cargarLibros() async {
    final conn = await DBConnection.getConnection();
    final results = await conn.query(
      'SELECT isbn, titulo, autores, editorial, anio_publicacion, num_ejemplar '
          'FROM libro ORDER BY isbn, num_ejemplar',
    );
    return results.map((r) => r.toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Consulta General de Libros',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<List<dynamic>>>(
          future: _futureLibros,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Color(0xFFE53935))));
            }

            final libros = snapshot.data!;

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
                      DataColumn(label: Text('ISBN')),
                      DataColumn(label: Text('Título')),
                      DataColumn(label: Text('Autores')),
                      DataColumn(label: Text('Editorial')),
                      DataColumn(label: Text('Año')),
                      DataColumn(label: Text('Ejemplar')),
                    ],
                    rows: libros.map((l) => DataRow(cells: [
                      DataCell(Text(l[0].toString())),
                      DataCell(Text(l[1].toString())),
                      DataCell(Text(l[2].toString())),
                      DataCell(Text(l[3].toString())),
                      DataCell(Text(l[4].toString())),
                      DataCell(Text(l[5].toString())),
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