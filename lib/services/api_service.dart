import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constant.dart';

class ApiService {
  /// Decode response body safely.
  /// Jika Laravel return HTML (misal error 404/500), lempar exception yang jelas.
  static dynamic _decode(http.Response response) {
    final body = response.body.trim();
    if (body.startsWith('<')) {
      // Laravel return HTML — biasanya route salah atau server error
      throw Exception(
        'Server mengembalikan HTML bukan JSON '
        '(status ${response.statusCode}). '
        'Periksa baseUrl dan endpoint.',
      );
    }
    return jsonDecode(body);
  }

  // ── GET ──────────────────────────────────────────────────────────────────────
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      print('GET  ${ApiConstant.baseUrl}/$endpoint → ${response.statusCode}');
      return _decode(response);
    } catch (e) {
      print('GET ERROR: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── POST ─────────────────────────────────────────────────────────────────────
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      print('POST ${ApiConstant.baseUrl}/$endpoint');
      print('DATA: $data');
      final response = await http
          .post(
            Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      print('STATUS: ${response.statusCode}');
      print('BODY  : ${response.body}');
      return _decode(response);
    } catch (e) {
      print('POST ERROR: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── PUT ──────────────────────────────────────────────────────────────────────
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      print('PUT  ${ApiConstant.baseUrl}/$endpoint');
      print('DATA: $data');
      final response = await http.put(
        Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('STATUS: ${response.statusCode}');
      print('BODY  : ${response.body}');
      return _decode(response);
    } catch (e) {
      print('PUT ERROR: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── DELETE ───────────────────────────────────────────────────────────────────
  static Future<dynamic> delete(String endpoint) async {
    try {
      print('DEL  ${ApiConstant.baseUrl}/$endpoint');
      final response = await http.delete(
        Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      print('STATUS: ${response.statusCode}');
      print('BODY  : ${response.body}');
      return _decode(response);
    } catch (e) {
      print('DEL ERROR: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── UPLOAD FILE ──────────────────────────────────────────────────────────────
  static Future<dynamic> uploadFile(
    String endpoint,
    String filePath, {
    Map<String, String>? fields,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstant.baseUrl}/$endpoint'),
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      if (fields != null) request.fields.addAll(fields);

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('STATUS: ${response.statusCode}');
      print('BODY  : $responseBody');
      return response.statusCode;
    } catch (e) {
      print('UPLOAD ERROR: $e');
      return 500;
    }
  }
}