import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constant.dart';

class ApiService {
  // GET request
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // POST request
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  // File upload
  static Future<dynamic> uploadFile(
  String endpoint,
  String filePath, {
  Map<String, String>? fields,
}) async {

  var request = http.MultipartRequest(
    'POST',
    Uri.parse(
      '${ApiConstant.baseUrl}/$endpoint',
    ),
  );

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      filePath,
    ),
  );

  if (fields != null) {
  request.fields.addAll(fields);
}

  var response = await request.send();

  final responseBody =
      await response.stream.bytesToString();

  print('STATUS: ${response.statusCode}');
  print('BODY: $responseBody');

  return response.statusCode;
}
}
