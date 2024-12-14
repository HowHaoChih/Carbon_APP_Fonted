import 'package:postgres/postgres.dart';

class DBService {
  late PostgreSQLConnection _connection;

  Future<void> initializeConnection() async {
    _connection = PostgreSQLConnection(
      '26.11.106.122',
      5432,
      'csv_storage',
      username: 'user',
      password: '12345678',
    );

    try {
      await connection.open();
      print('Database connection established.');
    } catch (e) {
      print('fail to connect database: $e');
    }
  }

  PostgreSQLConnection get connection => _connection;
}
