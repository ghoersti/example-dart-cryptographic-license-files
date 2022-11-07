import 'dart:ffi';
import 'package:postgres/postgres.dart';

//DB made locally, this is for exploration purposes
//TODO: load pw from ENV
void main() async {
  var connection = PostgreSQLConnection("localhost", 5433, "testdb",
      username: "postgres", password: "postgres");
  await connection.open();
  List<List<dynamic>> results =
      await connection.query("SELECT id, userblob, email FROM public.user;");
  //WHERE email = @aValue",
  //substitutionValues: {"aValue": 3});
  print(results);
  for (final row in results) {
    var id = row[0];
    var userblob = row[1];
    var email = row[2];
  }

  connection.close();
}
