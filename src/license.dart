import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as u;
import 'package:crypto/crypto.dart' as crypto;
import '../utils/utils.dart' as utils;

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

//CREATE LICENSE
createLicense(Map<String, String> h, String policyid, String userid) async {
  // var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/licenses');

  var body = convert.json.encode({
    "data": {
      "type": "licenses",
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
  var response = await http.post(
      Uri.parse('https://api.keygen.sh/v1/accounts/$acc/licenses'),
      headers: h,
      body: body);
  if (response.statusCode == 201) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    print("\n");
    final id = jsonResponse['data']['id'];
    utils.writeFile('../data/licenses/$id.json', jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with status : ${response.body}.');
  }
}

createLicenseToken(Map<String, String> h, String licenseid) async {
  final String demo_uuid = u.Uuid().v4();
  var body = convert.json.encode({
    "data": {
      "type": "tokens",
      "attributes": {"name": 'DEMO-ACT-$demo_uuid', "maxActivations": 1000000}
    }
  });
  var response = await http.post(
      Uri.parse(
          'https://api.keygen.sh/v1/accounts/$acc/licenses/$licenseid/tokens'),
      headers: h,
      body: body);
  if (response.statusCode == 201 || response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    print("\n");
    final tkn = await jsonResponse['data']['attributes']['token'];
    utils.writeFile('../data/tokens/$tkn.json', jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with status : ${response.statusCode}.');
  }
}

//This can be retieved before a file is activated
getLicenseFile(h, String act_token, String lid) async {
  var url = Uri.parse(
      "https://api.keygen.sh/v1/accounts/$acc/licenses/$lid/actions/check-out");
  print('$act_token');
  h.remove('Content-Type');
  h['Authorization'] = "Bearer $act_token";
  print(h);

  try {
    var response = await http.get(url, headers: h);
    print("\nLICENSE-FILE:\n${response.body}");
    if (response.statusCode == 200) {
      print('TWO HUNID');
      print("\nLICENSE-FILE:\n${response.body}");
      utils.writeFile('../data/license_files/$lid.lic', response.body);
      return response.body;
    } else {
      print('Request failed with : ${response.body}.');
      return convert.jsonDecode(response.body) as Map<String, dynamic>;
    }
  } catch (err) {
    print('ERROR: $err');
  }
}

void main() async {
  await utils.createDirectories();
  String policy_id = "66af0bab-1150-45b5-94a8-041335659c42";
  // String purl = utils.readStdin('Product URL');
  //mark mark
  String user_id = '103b7f20-04e9-40e2-9d39-067592d998e2';
  print("\nCREATING LICENSE\n");
  final Map<String, dynamic> license_response =
      await createLicense(head, policy_id, user_id);
  final String license_id = await license_response['data']['id'];

  print("\nCREATING LICENSE/ACTIVATION TOKEN\n");
  final Map<String, dynamic> tkn_response =
      await createLicenseToken(head, license_id);

  final String license_activation_token =
      await tkn_response['data']['attributes']['token'];

  // print('Activation Token: $license_activation_token');
}
