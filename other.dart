import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

void main(List<String> arguments) async {
  // This example uses the Google Books API to search for books about http.
  // https://developers.google.com/books/docs/overview
  var search_str = '{donkey}';
  var url = Uri.https('api.keygen.sh', '/books/v1/volumes', {'q': search_str});

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var jsonResponse =
        convert.jsonDecode(response.body) as Map<String, dynamic>;
    var itemCount = jsonResponse['totalItems'];
    print('Number of books about $search_str : $itemCount.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}
