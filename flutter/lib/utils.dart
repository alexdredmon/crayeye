// FILENAME: utils.dart

import 'dart:convert';

// Method to encode a string to Base64
String encode_b64(String input) {
  List<int> inputBytes = utf8.encode(input);
  String encoded = base64.encode(inputBytes);
  return encoded;
}

// Method to decode a Base64 encoded string
String decode_b64(String encoded) {
  List<int> decodedBytes = base64.decode(encoded);
  String decoded = utf8.decode(decodedBytes);
  return decoded;
}

// eof
