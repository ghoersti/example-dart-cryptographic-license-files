//https://keygen.sh/docs/api/policies/
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'demoLicense.dart' as al;
import '../utils/utils.dart' as utils;
import 'dart:io' show Platform;
import 'package:dcli/dcli.dart';

Map<String, String> head = {
  'Content-Type': 'application/vnd.api+json',
  'Accept': 'application/vnd.api+json',
  'Authorization': 'Bearer $tkn'
};

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];
//Creates Policy
createPolicy(Map<String, String> h, String productId, String policyName) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/policies');
  var body = convert.json.encode({
    'data': {
      'type': 'policies',
      'attributes': {
        'name': '$policyName',
        'strict': false,
        'floating': true,
        'scheme': 'ED25519_SIGN', //needed for offline license
        'maxMachines': 1000,
        'fingerprintUniquenessStrategy': 'UNIQUE_PER_LICENSE',
      },
      'relationships': {
        'product': {
          'data': {'type': 'product', 'id': '$productId'}
        }
      }
    }
  });
  var response = await http.post(url, headers: h, body: body);
  if (response.statusCode == 201) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    print('\n');
    final id = jsonResponse['data']['id'];
    await utils.writeFile('../data/policies/$id.json', jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed status : ${response.body}.');
  }
}

void main() async {
  //TODO: product hardcoded 1 product for now.
  String pname = ask(blue('Input Policy Name:'));
  print('=> $pname');
  String product_id = '0e62c7cc-74da-42e6-a0b8-2e7a3419867d';
  print(green('\nCREATING POLICY \n'));
  createPolicy(head, product_id, pname);
}
