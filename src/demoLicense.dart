import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;
import '../utils/utils.dart' as utils;
import '../user.dart' as usr;
import 'product.dart' as product;
import 'policy.dart' as policy;
import 'license.dart' as lic;

//Create Directories
//TODO: refactor all this and add to utils or use db

//ACTIVATE LICENSE
void main() async {
  print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  // utils.createDirectories();
  // utils.readFile('./.env');
  // utils.listDirectories('.');
  // var user_response = usr.createUser(head, stdin_flag: true);
  createLicense(head, "hey", "no");
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
