import 'dart:ffi';
import 'package:postgres/postgres.dart';

//To restart postgresql@15 after an upgrade:
//   brew services restart postgresql@15
// Or, if you don't want/need a background service you can just run:
//   /opt/homebrew/opt/postgresql@15/bin/postgres -D /opt/homebrew/var/postgresql@15

// connect() async {
//   var connection = PostgreSQLConnection("localhost", 5433, "testdb",
//       username: "postgres", password: "postgres");
//   await connection.open();
// }

void main() async {
  var connection = PostgreSQLConnection("localhost", 5433, "testdb",
      username: "postgres", password: "postgres");
  await connection.open();
  List<List<dynamic>> results =
      await connection.query("SELECT id,userblob, email FROM public.user;");
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
