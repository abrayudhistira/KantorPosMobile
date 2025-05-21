import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kantorpos/model/uangmasuk.dart';

class UangMasukService {
  static const _baseUrl = 'https://aa1f-103-3-222-72.ngrok-free.app';

  Future<List<UangMasuk>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/uangmasuk');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => UangMasuk.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }

  Future<UangMasuk> createUangMasuk(UangMasuk uangMasuk) async {
    final url = Uri.parse('$_baseUrl/uangmasukadd');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(uangMasuk.toJson()),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return uangMasuk;
    } else {
      throw Exception('Failed to create Uang Masuk');
    }
  }

  Future<void> updateUangMasuk(UangMasuk uangMasuk) async {
    final url = Uri.parse('$_baseUrl/uangmasuk/${uangMasuk.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(uangMasuk.toJson()),
    );
    print('Update status code: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update Uang Masuk');
    }
  }

  Future<void> deleteUangMasuk(int id) async {
    final url = Uri.parse('$_baseUrl/uangmasuk/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Uang Masuk');
    }
  }
}