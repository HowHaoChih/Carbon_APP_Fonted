import '../services/db_service.dart';

class UserRepository {
  final DBService dbService;

  UserRepository(this.dbService);

  Future<List<List<dynamic>>> GetData(String department) async {
    List<List<dynamic>> data = [];
    String instruction = 'SELECT * FROM ';
    instruction = instruction + department;
    try {
      List<List<dynamic>> results =
          await dbService.connection.query(instruction);
      for (var row in results) {
        data.add(row);
      }
    } catch (e) {
      print('Error : $e');
    }
    return data;
  }
}
