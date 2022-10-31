import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;

readStdin(String printmsg) {
  stdout.write("$printmsg : ");
  var input = stdin.readLineSync();
  stdout.write('$input\n');
  return input;
}

listDirectory(String dir_path) async {
  var dir = Directory('$dir_path');

  try {
    var dirList = dir.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is File) {
        print('Found file ${f.path}');
      } else if (f is Directory) {
        print('Found dir ${f.path}');
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

createDirectory(String dir) async {
  try {
    Directory('./$dir').create(recursive: true);
  } catch (e) {
    print(e.toString());
  }
}

createDirectories() async {
  try {
    createDirectory("data/licenses");
    createDirectory("data/users");
    createDirectory("data/policies");
    createDirectory("data/products");
  } catch (e) {
    print(e.toString());
  }
}

readFile(String filepath) async {
  var config = File('$filepath');
  try {
    var contents = await config.readAsString();
    print(contents);
    return contents;
  } catch (e) {
    print(e);
  }
}

writeFile(String filepath, data) async {
  var config = File('$filepath');
  try {
    var f = File('$filepath');
    var sink = f.openWrite();
    sink.write('$data');
    await sink.flush();
    await sink.close();
    print('File $filepath created. ');
  } catch (e) {
    print(e);
  }
}

//NOTE this all happens after succesful payment with stripe
//ENV vars & request headers
//TODO more status codes
var env = DotEnv(includePlatformEnvironment: true)..load(['./.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

hashit({String strHash: 'DUMMY_FINGERPRINT'}) {
  var bytes = convert.utf8.encode(strHash);
  var hash = crypto.sha1.convert(bytes);
  return hash;
}

//CREATE USER
//TODO: Need a delete user
// retrieve user
// update user
createUser(h, {bool stdin_flag: false}) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/users');
  //When account is unprotected auth is not needed
  // h.remove('Authorization');
  // print(h);
  if (stdin_flag == false) {
    var name = uuid.Uuid().v4();
    var body = convert.json.encode({
      "data": {
        "type": "users",
        "attributes": {
          "firstName": "John",
          "lastName": "Doe_$name",
          "email": "jdoe_$name@keygen.sh",
          "password": "secret"
        }
      }
    });
  } else {
    String fname = readStdin('Enter FirstName');
    String lname = readStdin('Enter LastName');
    String email = readStdin('Enter Email');
    String pw = readStdin('Enter Password');
    var body = convert.json.encode({
      "data": {
        "type": "users",
        "attributes": {
          "firstName": "$fname",
          "lastName": "$lname",
          "email": "$email",
          "password": "$pw"
        }
      }
    });

    var response = await http.post(url, headers: h, body: body);
    //201 create
    if (response.statusCode == 201) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse);
      //hash of email for filename
      var usr_email_hash = hashit(strHash: '$email');
      var usr_json = './data/users/$usr_email_hash.json';
      writeFile('$usr_json', jsonResponse);

      return jsonResponse;
    } else {
      print('Request failed status : ${response.body}.');
    }
  }
}

// get license ID
// Needs user token
whoami(h, String user_token) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/me');
  h.remove('Content-Type');
  h['Authorization'] = "Bearer $user_token";
  var response = await http.post(
    url,
    headers: h,
  );
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with : ${response.statusCode}.');
  }
}

//CREATE LICENSE
// get license ID
createLicense(h, policyid, userid) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/licenses');
  var response = await http.post(
    url,
    headers: h,
  );
  var body = convert.json.encode({
    "data": {
      "type": "users",
      "relationships": {
        "policy": {
          "data": {"type": "policies", "id": "$policyid"}
        },
        "user": {
          "data": {"type": "users", "id": "$userid"}
        }
      }
    }
  });
  if (response.statusCode == 201) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with status : ${response.statusCode}.');
  }
}

//Create Directories
//TODO: refactor all this and add to utils or use db

//ACTIVATE LICENSE
void main() async {
  print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  createDirectories();
  readFile('./.env');
  listDirectory('.');

  var user_response = createUser(head, stdin_flag: true);
}
//   createUser(head);
//   whoami(head);
//   var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/machines');
//   //device fingerprint
//   // will use  https://pub.dev/packages/platform_device_id in flutter
//   // but for now ill just use a dummy hash
//   var bytes = convert.utf8.encode('DUMMY_FINGERPRINT');
//   var fingerprint = crypto.sha1.convert(bytes);

//   var body = convert.json.encode({
//     "data": {
//       "type": "machines",
//       "attributes": {
//         "fingerprint": '$fingerprint',
//         "platform": "Darwin",
//         "name": "Office MacBook Pro"
//       },
//       "relationships": {
//         "license": {
//           "data": {
//             "type": "licenses",
//             "id": "a164d201-87f5-4fc2-9ac1-49b7115efd54"
//           }
//         }
//       }
//     }
//   });

//   // print(head);
//   var response = await http.post(url, headers: head, body: body);

//   print('Machine fingerprint: $fingerprint');

//   if (response.statusCode == 200) {
//     var jsonResponse =
//         convert.jsonDecode(response.body) as Map<String, dynamic>;
//   } else {
//     print('Request failed with : ${response.statusCode}.');
//   }
// }
// }
