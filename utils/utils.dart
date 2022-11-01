import 'package:args/args.dart';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';
import 'package:uuid/uuid.dart' as uuid;
import 'package:crypto/crypto.dart' as crypto;

Map<String, String> head = {
  "Content-Type": "application/vnd.api+json",
  "Accept": "application/vnd.api+json",
  "Authorization": "Bearer $tkn"
};

var env = DotEnv(includePlatformEnvironment: true)..load(['../.env']);
var acc = env['KEYGEN_ACCOUNT_ID'];
var pub = env['KEYGEN_PUBLIC_KEY'];
var tkn = env['TOKEN'];

readStdin(String printmsg) {
  stdout.write("$printmsg : ");
  var input = stdin.readLineSync();
  stdout.write('$input\n');
  return input;
}

listDirectories(String dir_path) async {
  var dir = Directory('$dir_path');

  try {
    var dirList = dir.list();
    await for (final FileSystemEntity f in dirList) {
      if (f is File) {
        print('Found file ${f.path}');
      } else if (f is Directory) {
        print('Found dir ${f.path}');
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

createDirectory(String dir) async {
  try {
    Directory('../$dir').create(recursive: true);
  } catch (e) {
    print(e.toString());
  }
}

createDirectories() async {
  try {
    createDirectory("data/licenses");
    createDirectory("data/users");
    createDirectory("data/policies");
    createDirectory("data/products");
  } catch (e) {
    print(e.toString());
  }
}

readFile(String filepath) async {
  var config = File('$filepath');
  try {
    var contents = await config.readAsString();
    print(contents);
    return contents;
  } catch (e) {
    print(e);
  }
}

writeFile(String filepath, data) async {
  var config = File('$filepath');
  try {
    var f = File('$filepath');
    var sink = f.openWrite();
    sink.write('$data');
    await sink.flush();
    await sink.close();
    print('File $filepath created. ');
  } catch (e) {
    print(e);
  }
}

hashit({String strHash: 'DUMMY_FINGERPRINT'}) {
  var bytes = convert.utf8.encode(strHash);
  var hash = crypto.sha1.convert(bytes);
  return hash;
}
