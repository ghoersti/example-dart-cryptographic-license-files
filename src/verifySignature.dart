import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:dcli/dcli.dart';

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

offlineVerification(String license_file, String license_key) async {
  var decoder = utf8.fuse(base64);
  var cert = license_file;
  var enc = cert
      .replaceFirst('-----BEGIN LICENSE FILE-----', "")
      .replaceFirst('-----END LICENSE FILE-----', "")
      .replaceAll('\n', '');

  var dec = decoder.decode(enc);
  var lic = json.decode(dec);
  // Assert algorithm is supported
  //'aes-256-gcm+ed25519'
  if (lic['alg'] != 'base64+ed25519') {
    throw new Exception('unsupported license file algorithm');
  }

  // Verify the license file's signature

  bool ok;

  try {
    var pubkey = SimplePublicKey(hex.decode('$pub'), type: KeyPairType.ed25519);
    var msg = Uint8List.fromList(utf8.encode("license/" + lic['enc']));
    var sig = base64.decode(lic['sig']);
    var ed = Ed25519();

    ok = await ed.verify(msg, signature: Signature(sig, publicKey: pubkey));
  } catch (e) {
    throw new Exception('failed to verify license file: $e');
  }

  if (!ok) {
    throw new Exception('invalid license file signature');
  }
  // Print license file
  print("license file was successfully verified!");
  print("  > $lic");
  var data = decoder.decode(lic['enc']);
  print('$data');
  return data;
}
