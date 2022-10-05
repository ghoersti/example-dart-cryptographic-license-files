import 'package:cryptography/cryptography.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

void main(List<String> argv) async {
  final decoder = utf8.fuse(base64);
  final parser = ArgParser();
  final ed = Ed25519();

  parser.addOption('license-file', abbr: 'f', mandatory: true);
  parser.addOption('license-key', abbr: 'k', mandatory: true);
  parser.addOption('public-key', abbr: 'p', mandatory: true);

  final args = parser.parse(argv);

  // Read and parse license file
  var cert = await File(args['license-file']).readAsString();
  var enc = cert.replaceFirst('-----BEGIN LICENSE FILE-----', "")
                .replaceFirst('-----END LICENSE FILE-----', "")
                .replaceAll('\n', '');

  var dec = decoder.decode(enc);
  var lic = json.decode(dec);

  // Assert algorithm is supported
  if (lic['alg'] != 'aes-256-gcm+ed25519') {
    throw new Exception('unsupported license file algorithm');
  }

  // Verify the license file's signature
  var pubkey = SimplePublicKey(hex.decode(args['public-key']), type: KeyPairType.ed25519);
  var msg = Uint8List.fromList(utf8.encode("license/" + lic['enc']));
  var sig = base64.decode(lic['sig']);
  bool ok;

  try {
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

  // Hash the license key to obtain decryption secret
  final digest = sha256.convert(utf8.encode(args['license-key']));
  final key = SecretKey(digest.bytes);

  // Parse the encrypted dataset
  var parts = (lic['enc'] as String).split('.').map((s) => base64.decode(s)).toList();
  var ciphertext = parts[0];
  var nonce = parts[1];
  var mac = parts[2];

  // Decrypt the license file's dataset
  final aes = AesGcm.with256bits(nonceLength: 16);
  String plaintext;

  try {
    var bytes = await aes.decrypt(
      SecretBox(ciphertext, mac: Mac(mac), nonce: nonce),
      secretKey: key,
    );

    plaintext = utf8.decode(bytes);
  } catch (e) {
    throw new Exception('failed to decrypt license file: $e');
  }

  // Print decrypted dataset
  var data = json.decode(plaintext);

  print("license file was successfully decrypted!");
  print("  > $data");
}
