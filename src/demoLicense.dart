//TODO: fix & sort imports
//TODO: refactor all this and add to utils or use db
//TODO: sort packages
//TODO: strongly type
//TODO: readme

import 'package:args/args.dart';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:crypto/crypto.dart' as crypto;
import '../utils/utils.dart' as utils;
import 'user.dart' as usr;
import 'product.dart' as product;
import 'policy.dart' as policy;
import 'license.dart' as lic;

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

//Create Directories
//TODO: refactor all this and add to utils or use db
//TODO: sort packages
//TODO: strongly type

//ACTIVATE LICENSE
void main() async {
  print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  utils.createDirectories();
  //product
  final String pname = await utils.readStdin('Product Name');
  final String purl = 'https://test.com';
  print("\nCREATING PRODUCT\n");
  final Map<String, dynamic> product_response =
      await product.createProduct(head, pname, purl);
  String product_id = product_response['data']['id'];

  //policy
  print("\nCREATING POLICY\n");
  String policy_name = utils.readStdin("Product URL");
  final Map<String, dynamic> policy_response =
      await policy.createPolicy(head, product_id, policy_name);
  //user
  print("\nCREATING USER\n");
  final Map<String, dynamic> user_response =
      await usr.createUser(head, stdin_flag: true);
  //license
  final policy_id = policy_response['data']['id'];
  final user_id = user_response['data']['id'];
  print("\nCREATING LICENSE\n");
  final Map<String, dynamic> license_response =
      await lic.createLicense(head, policy_id, user_id);
  final String license_id = license_response['data']['id'];
  final url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/machines');

  //device fingerprint
  // TODO: see if we can do in dart
  // will use  https://pub.dev/packages/platform_device_id in flutter
  // but for now ill just use a dummy hash
  final bytes = convert.utf8.encode('DUMMY_FINGERPRINT');
  final fingerprint = crypto.sha1.convert(bytes);

  var body = convert.json.encode({
    "data": {
      "type": "machines",
      "attributes": {
        "fingerprint": '$fingerprint',
        "platform": "Darwin",
        "name": "Office MacBook Pro"
      },
      "relationships": {
        "license": {
          "data": {"type": "licenses", "id": "$license_id"}
        }
      }
    }
  });
  var response = await http.post(url, headers: head, body: body);

  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    print('Request failed with : ${response.statusCode}.');
  }
}
