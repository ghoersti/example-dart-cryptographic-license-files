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
import 'package:dcli/dcli.dart';

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
  //print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  utils.createDirectories();
  //product
  String pname = ask(blue('Enter Product Name:'));
  print('=> $pname');
  String purl = ask(blue('Enter Product Url:'));
  print('=> $purl');
  print(green('CREATING PRODUCT \n'));
  final Map<String, dynamic> product_response =
      await product.createProduct(head, pname, purl);
  String product_id = product_response['data']['id'];

  //policy
  print(green('\nCREATING POLICY\n'));
  String polname = ask(blue('Enter Policy Name:'));
  print('=> $polname');
  print(green('CREATING PRODUCT \n'));
  final Map<String, dynamic> policy_response =
      await policy.createPolicy(head, product_id, polname);
  //user
  print(green('\nCREATING USER\n'));
  final Map<String, dynamic> user_response = await usr.createUser(head);
  //license
  final policy_id = policy_response['data']['id'];
  final user_id = user_response['data']['id'];
  print(green('\nCREATING LICENSE\n'));
  final Map<String, dynamic> license_response =
      await lic.createLicense(head, policy_id, user_id);
  final String license_id = license_response['data']['id'];
  final url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/machines');

  //device fingerprint
  // TODO: move to CLI cmd
  // will use  https://pub.dev/packages/platform_device_id in flutter
  // but for now ill just use a dummy hash
  // final bytes = convert.utf8.encode('DUMMY_FINGERPRINT45');
  // final fingerprint = crypto.sha1.convert(bytes);
  final fingerprint = await utils.getFingerprint();
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

  if (response.statusCode == 200 || response.statusCode == 201) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(green("\nMachine Activated\n"));
    print(jsonResponse);
    print("\n");
  } else {
    print('Request failed with : ${response.statusCode}.');
  }
}
