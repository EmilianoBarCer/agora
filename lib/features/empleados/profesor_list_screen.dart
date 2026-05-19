import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class ProfesorListScreen extends StatefulWidget {
  const ProfesorListScreen({super.key});

  @override
  State<ProfesorListScreen> createState() => _ProfesorListScreenState();
}

class _ProfesorListScreenState extends State<ProfesorListScreen> {
  late Future<List<List<dynamic>>> _futureProfesores;

  @override
  void initState() {
    super.initState();
    _futureProfesores = _cargarProfesores();
  }

  Future<List<List<dynamic>>> _cargarProfesores() async {
    final conn = await DBConnection.getConnection();
    final results = await conn.query(
      'SELECT codigo, nombre, direccion, telefono, sexo, fecha_nacimiento, departamento, correo '
          'FROM profesor ORDER BY nombre',
    );
    return results.map((r) => r.toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Consulta General de Profesores',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<List<dynamic>>>(
          future: _futureProfesores,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Color(0xFFE53935))));
            }

            final profesores = snapshot.data!;

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
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Sexo')),
                      DataColumn(label: Text('Fecha Nac.')),
                      DataColumn(label: Text('Departamento')),
                      DataColumn(label: Text('Correo')),
                    ],
                    rows: profesores.map((p) => DataRow(cells: [
                      DataCell(Text(p[0].toString())),
                      DataCell(Text(p[1].toString())),
                      DataCell(Text(p[2].toString())),
                      DataCell(Text(p[3].toString())),
                      DataCell(Text(p[4].toString())),
                      DataCell(Text(p[5].toString().split(' ')[0])),
                      DataCell(Text(p[6].toString())),
                      DataCell(Text(p[7].toString())),
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