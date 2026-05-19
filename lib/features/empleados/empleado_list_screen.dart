import 'package:flutter/material.dart';
import '../../core/db_connection.dart';

class EmpleadoListScreen extends StatefulWidget {
  const EmpleadoListScreen({super.key});

  @override
  State<EmpleadoListScreen> createState() => _EmpleadoListScreenState();
}

class _EmpleadoListScreenState extends State<EmpleadoListScreen> {
  late Future<List<List<dynamic>>> _futureEmpleados;

  @override
  void initState() {
    super.initState();
    _futureEmpleados = _cargarEmpleados();
  }

  Future<List<List<dynamic>>> _cargarEmpleados() async {
    final conn = await DBConnection.getConnection();
    final results = await conn.query(
      'SELECT codigo, nombre, direccion, telefono, sexo, fecha_nacimiento, turno '
          'FROM empleado ORDER BY codigo',
    );
    return results.map((r) => r.toList()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2347),
        title: const Text('Consulta General de Empleados',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: FutureBuilder<List<List<dynamic>>>(
          future: _futureEmpleados,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString(),
                  style: const TextStyle(color: Color(0xFFE53935))));
            }

            final empleados = snapshot.data!;

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
                    headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF0D2347)),
                    headingTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    dataRowColor: WidgetStateProperty.resolveWith((states) {
                      return states.contains(WidgetState.selected)
                          ? const Color(0xFFE8EDF5)
                          : Colors.white;
                    }),
                    columns: const [
                      DataColumn(label: Text('Código')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Dirección')),
                      DataColumn(label: Text('Teléfono')),
                      DataColumn(label: Text('Sexo')),
                      DataColumn(label: Text('Fecha Nac.')),
                      DataColumn(label: Text('Turno')),
                    ],
                    rows: empleados.map((e) {
                      return DataRow(cells: [
                        DataCell(Text(e[0].toString())),
                        DataCell(Text(e[1].toString())),
                        DataCell(Text(e[2].toString())),
                        DataCell(Text(e[3].toString())),
                        DataCell(Text(e[4].toString())),
                        DataCell(Text(e[5].toString().split(' ')[0])),
                        DataCell(Text(e[6].toString())),
                      ]);
                    }).toList(),
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