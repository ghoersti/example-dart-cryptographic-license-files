//https://keygen.sh/docs/api/users/
import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;
import '../utils/utils.dart' as utils;
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

//CREATE USER
//TODO: Need a delete user
// retrieve user
// update user
//GUI
// https://app.keygen.sh/users
// DOCS
//https://keygen.sh/docs/api/users/

createUser(h) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/users');
  //When account is unprotected auth is not needed
  // h.remove('Authorization');
  // print(h);
  try {
    String fname = await ask(blue('Enter FirstName:'));
    print('=> $fname');
    String lname = await ask(blue('Enter LastName:'));
    print('=> $lname');
    String email = await ask(blue('Enter Email:'));
    print('=> $email');
    String pw = await ask(blue('Enter Password:'), hidden: true);
    var body = await convert.json.encode({
      'data': {
        'type': 'users',
        'attributes': {
          'firstName': '$fname',
          'lastName': '$lname',
          'email': '$email',
          'password': '$pw'
        }
      }
    });
    var response = await http.post(url, headers: h, body: body);
    if (response.statusCode == 201) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse);
      //hash of email for filename
      var usr_email_hash = utils.hashit(strHash: '$email');
      var usr_json = '../data/users/$usr_email_hash.json';
      utils.writeFile('$usr_json', jsonResponse);

      return jsonResponse;
    } else {
      print('Request failed status : ${response.body}.');
    }
  } catch (e) {
    print(e);
  }
  ;
}

//TODO: can you verify without having to authenticate

// get license ID
// TODO: Needs user token as bearer
// multiple activations
whoami(h, String token) async {
  var url = Uri.parse('https://api.keygen.sh/v1/accounts/$acc/me');
  print('$token');
  h.remove('Content-Type');
  h['Authorization'] = 'Bearer $token';
  try {
    var response = await http.get(url, headers: h);

    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      print(jsonResponse);
      return jsonResponse;
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

  print(green('\nCREATING USER'));
  final Map<String, dynamic> tkn_retrieve = await createUser(head);
}
