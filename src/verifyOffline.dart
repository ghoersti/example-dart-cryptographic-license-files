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
import 'user.dart' as user;
import 'product.dart' as product;
import 'policy.dart' as policy;
import 'license.dart' as lic;
import 'verifySignature.dart' as verify;
import 'package:dcli/dcli.dart';

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

final String policy_id = '66af0bab-1150-45b5-94a8-041335659c42';
// final String user_id = '84b305fd-1cdd-40e0-8d49-321728e3fc49';

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

//TODO: plop this in after payment machine activation
// device fingerprint
// TODO: see if we can do in dart
// will use  https://pub.dev/packages/platform_device_id in flutter
// but for now ill just use a dummy hash

//Create Directories
//TODO: refactor all this and add to utils or use db
//TODO: sort packages
//TODO: strongly type
//TODO: Add or not add machine activation?
//GET TOKEN->HIT WHOAMI -> GET LICENSE -> ACTIVATE LICENSE VERIFY MACHINE OFFINE
void main() async {
  //print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  utils.createDirectories();
  final String license_activation_token =
      await "activ-037d00e8791b2667b4c92269afb3bb47v3";

  print("\nGET USING ACTIVATION TOKEN\n");
  final Map<String, dynamic> license_resp =
      await user.whoami(head, license_activation_token);
  String license_id = await license_resp['data']['id'];
  String license_key = await license_resp['data']['attributes']['key'];
  // checkout license file
  //https://keygen.sh/docs/api/licenses/#licenses-actions-check-out
  //Using a get here to just snatch the license file write away
  var license =
      await lic.getLicenseFile(head, license_activation_token, license_id);
  // utils.writeFile('../data/license_files/$license_id.lic', license);
  Map<String, dynamic> data =
      await verify.offlineVerification(license, license_key);

  lic.activateWithLicenseToken(head, license_id, license_activation_token);
}
