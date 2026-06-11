import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';


class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for desktop/web, or your local network IP (e.g. 192.168.1.8)
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // Fallback url for emulator testing
  static const String emulatorUrl = 'http://10.0.2.2:8000/api';

  static String getEffectiveUrl(String path) {
    // Return the default endpoint path
    return '$baseUrl$path';
  }

  // Get active session token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Set active session token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear session
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Fetch reference data for dropdowns
  static Future<Map<String, dynamic>?> getReferenceData() async {
    try {
      final response = await http.get(Uri.parse(getEffectiveUrl('/reference-data')));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Fallback to emulator URL if localhost fails
      try {
        final response = await http.get(Uri.parse('$emulatorUrl/reference-data'));
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (_) {}
    }
    return null;
  }

  // Register Nelayan
  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(getEffectiveUrl('/nelayan/register')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      try {
        final response = await http.post(
          Uri.parse('$emulatorUrl/nelayan/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );
        return jsonDecode(response.body);
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
      }
    }
  }

  // Login Nelayan
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(getEffectiveUrl('/nelayan/login')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await saveToken(result['token']);
      }
      return result;
    } catch (e) {
      try {
        final response = await http.post(
          Uri.parse('$emulatorUrl/nelayan/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        );
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          await saveToken(result['token']);
        }
        return result;
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
      }
    }
  }

  // Get Profil Nelayan
  static Future<Map<String, dynamic>?> getProfile() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(getEffectiveUrl('/nelayan/profile')),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      try {
        final response = await http.get(
          Uri.parse('$emulatorUrl/nelayan/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (_) {}
    }
    return null;
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final token = await getToken();
    if (token == null) return {'status': 'error', 'message': 'Unauthorized'};

    try {
      final response = await http.put(
        Uri.parse(getEffectiveUrl('/nelayan/profile/update')),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      return jsonDecode(response.body);
    } catch (e) {
      try {
        final response = await http.put(
          Uri.parse('$emulatorUrl/nelayan/profile/update'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );
        return jsonDecode(response.body);
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal terhubung ke server.'};
      }
    }
  }

  // Get Catches
  static Future<Map<String, dynamic>?> getCatches() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse(getEffectiveUrl('/nelayan/catches')),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      try {
        final response = await http.get(
          Uri.parse('$emulatorUrl/nelayan/catches'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      } catch (_) {}
    }
    return null;
  }

  // Submit new catch with photo
  static Future<Map<String, dynamic>> storeCatch({
    required String tanggal,
    required String jenisIkanId,
    required double berat,
    required XFile fotoFile,
  }) async {
    final token = await getToken();
    if (token == null) return {'status': 'error', 'message': 'Unauthorized'};

    try {
      return await _multipartSubmit(
        url: getEffectiveUrl('/nelayan/catches/store'),
        token: token,
        tanggal: tanggal,
        jenisIkanId: jenisIkanId,
        berat: berat,
        fotoFile: fotoFile,
      );
    } catch (e) {
      try {
        return await _multipartSubmit(
          url: '$emulatorUrl/nelayan/catches/store',
          token: token,
          tanggal: tanggal,
          jenisIkanId: jenisIkanId,
          berat: berat,
          fotoFile: fotoFile,
        );
      } catch (_) {
        return {'status': 'error', 'message': 'Gagal mengirim data.'};
      }
    }
  }

  static Future<Map<String, dynamic>> _multipartSubmit({
    required String url,
    required String token,
    required String tanggal,
    required String jenisIkanId,
    required double berat,
    required XFile fotoFile,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['tanggal'] = tanggal;
    request.fields['jenis_ikan_id'] = jenisIkanId;
    request.fields['berat'] = berat.toString();

    final bytes = await fotoFile.readAsBytes();
    final filename = path.basename(fotoFile.path);

    final multipartFile = http.MultipartFile.fromBytes(
      'foto',
      bytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    );

    request.files.add(multipartFile);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    // Debug logging to help troubleshooting uploads
    if (kDebugMode) {
      try {
        print('[_multipartSubmit] URL: $url');
        print('[_multipartSubmit] Status: ${response.statusCode}');
        print('[_multipartSubmit] Body: ${response.body}');
      } catch (_) {}
    }

    // Try to parse JSON if possible, otherwise return an error with status
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body is Map<String, dynamic> ? body : {'status': 'success', 'data': body};
      }
      // If server returned an error, try to extract message
      if (body is Map<String, dynamic> && body['message'] != null) {
        return {'status': 'error', 'message': body['message']};
      }
      return {'status': 'error', 'message': 'Server returned ${response.statusCode}'};
    } catch (e) {
      return {'status': 'error', 'message': 'Invalid server response.'};
    }
  }
}
