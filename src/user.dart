import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;
import '../utils/utils.dart' as utils;

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

//CREATE USER
//TODO: Need a delete user
// retrieve user
// update user
createUser(h, {bool stdin_flag: false}) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/users');
  //When account is unprotected auth is not needed
  // h.remove('Authorization');
  // print(h);
  if (stdin_flag == false) {
    var name = uuid.Uuid().v4();
    var body = convert.json.encode({
      "data": {
        "type": "users",
        "attributes": {
          "firstName": "John",
          "lastName": "Doe_$name",
          "email": "jdoe_$name@keygen.sh",
          "password": "secret"
        }
      }
    });
  } else {
    String fname = utils.readStdin('Enter FirstName');
    String lname = utils.readStdin('Enter LastName');
    String email = utils.readStdin('Enter Email');
    String pw = utils.readStdin('Enter Password');
    var body = convert.json.encode({
      "data": {
        "type": "users",
        "attributes": {
          "firstName": "$fname",
          "lastName": "$lname",
          "email": "$email",
          "password": "$pw"
        }
      }
    });

    var response = await http.post(url, headers: h, body: body);
    //201 create
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
  }
}

// get license ID
// TODO: Needs user token as bearer
// multiple activations
whoami(h, String user_token) async {
  var url = Uri.https('api.keygen.sh', '/v1/accounts/$acc/me');
  h.remove('Content-Type');
  h['Authorization'] = "Bearer $user_token";
  var response = await http.post(
    url,
    headers: h,
  );
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    print(jsonResponse);
    return jsonResponse;
  } else {
    print('Request failed with : ${response.statusCode}.');
  }
}
