import 'package:postgres/postgres.dart';

class DBConnection {
  static PostgreSQLConnection? _connection;

  static Future<PostgreSQLConnection> getConnection() async {
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
        'localhost',   // host
        5432,          // puerto
        'Biblioteca',  // nombre de la base de datos
        username: 'postgres',
        password: '1109',
        useSSL: false,
      );
      await _connection!.open();
    }
    return _connection!;
  }
}