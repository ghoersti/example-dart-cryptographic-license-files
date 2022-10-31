import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;
import 'utils/utils.dart' as utils;

var env = DotEnv(includePlatformEnvironment: true)..load(['./.env']);
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
    utils.writeFile('./data/policies/$id.json', jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with status : ${response.body}.');
  }
}

void main() async {
  String pol_id = "3c87cd92-b909-4e4a-a683-533c8d2649d0";
  // String purl = utils.readStdin('Product URL');
  //mark mark
  String user_id = '103b7f20-04e9-40e2-9d39-067592d998e2';
  print("CREATING LICENSE\n");
  createLicense(head, pol_id, user_id);
}
