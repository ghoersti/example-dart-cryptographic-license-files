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
import 'license.dart' as lic;
import 'verifyDecrypt.dart' as decrypt;
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

//ACTIVATE LICENSE
void main() async {
  //print("Account : $acc \nPubKey: $pub \nToken: $tkn");
  //Filsystem acting as initial data store
  utils.createDirectories();
  final String license_activation_token =
      await "activ-037d00e8791b2667b4c92269afb3bb47v3";

  print(green("\nGET USING ACTIVATION TOKEN\n"));
  //RETIREIVE PERSIST LICENSE RESPONSE
  final Map<String, dynamic> license_resp =
      await usr.whoami(head, license_activation_token);
  String license_id = license_resp['data']['id'];
  String license_key = license_resp['data']['attributes']['key'];
  //ACTIVATE ON MACHINE
  //TODO: PERSIST MACHINE DATA , uses actual fingerprint now
  print(green("\nCHECKOUT & DECRYPT LICENSE FILE\n"));
  final Map<String, dynamic> activation_response = await lic
      .activateWithLicenseToken(head, license_id, license_activation_token);
  // CHECKOUT SAVE  LICENSE FILE
  //https://keygen.sh/docs/api/licenses/#licenses-actions-check-out
  //Using a POST here, GET will return only license file see **VerifySignature.dart
  var license_response = await lic.getEncryptedLicenseResponse(
      head, license_activation_token, license_id);
  String license = license_response['data']['attributes']['certificate'];

  // VERIFY SIGNATURE DECRYPT DATA
  print(green("\nACTIVATE MACHINE WITH ACT-TOKEN\n"));
  Map<String, dynamic> decrypted_data =
      await decrypt.offlineVerification(license, license_key);
}
