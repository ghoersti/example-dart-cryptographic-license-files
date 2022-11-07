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
//floating nonstrict policy
final String policy_id = 'f7fd71e4-b342-469d-98f7-5132babc1a62';
//Strict policy
// final String policy_id = '66af0bab-1150-45b5-94a8-041335659c42';
// final String user_id = '84b305fd-1cdd-40e0-8d49-321728e3fc49';

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

  //user
  print(green("\nCREATING USER\n"));
  final Map<String, dynamic> user_response = await usr.createUser(head);

  //license
  final user_id = user_response['data']['id'];

  //create license token
  print(green("\nCREATING LICENSE\n"));
  final Map<String, dynamic> license_response =
      await lic.createLicense(head, policy_id, user_id);
  final String license_id = await license_response['data']['id'];
  final String license_key =
      await license_response['data']['attributes']['key'];

  print(green("\nCREATING LICENSE/ACTIVATION TOKEN\n"));
  final Map<String, dynamic> tkn_response =
      await lic.createLicenseToken(head, license_id);

  final String license_activation_token =
      await tkn_response['data']['attributes']['token'];

  print(green("\nGET USING ACTIVATION TOKEN\n"));
  final Map<String, dynamic> tkn_retrieve =
      await usr.whoami(head, license_activation_token);
}
