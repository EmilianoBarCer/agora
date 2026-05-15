import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class AlumnoListScreen extends StatefulWidget {
  const AlumnoListScreen({super.key});

  @override
  State<AlumnoListScreen> createState() => _AlumnoListScreenState();
}

class _AlumnoListScreenState extends State<AlumnoListScreen> {
  late Future<List<List<dynamic>>> _futureAlumnos;

  @override
  void initState() {
    super.initState();
    _futureAlumnos = _cargarAlumnos();
  }

  Future<List<List<dynamic>>> _cargarAlumnos() async {
    final conn = await DBConnection.getConnection();
    final results = await conn.query(
      'SELECT codigo, nombre, carrera, correo, direccion, telefono, sexo, fecha_nacimiento '
          'FROM alumno ORDER BY nombre',
    );
    return results.map((r) => r.toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Consulta General de Alumnos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<List<dynamic>>>(
          future: _futureAlumnos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Color(0xFFE53935))));
            }

            final alumnos = snapshot.data!;

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
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Carrera')),
                      DataColumn(label: Text('Correo')),
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Sexo')),
                      DataColumn(label: Text('Fecha Nac.')),
                    ],
                    rows: alumnos.map((a) => DataRow(cells: [
                      DataCell(Text(a[0].toString())),
                      DataCell(Text(a[1].toString())),
                      DataCell(Text(a[2].toString())),
                      DataCell(Text(a[3].toString())),
                      DataCell(Text(a[4].toString())),
                      DataCell(Text(a[5].toString())),
                      DataCell(Text(a[6].toString())),
                      DataCell(Text(a[7].toString().split(' ')[0])),
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