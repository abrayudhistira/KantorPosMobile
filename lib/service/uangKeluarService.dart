import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kantorpos/model/uangkeluar.dart';

class UangKeluarService {
  static const _baseUrl = 'https://14a4-139-192-222-221.ngrok-free.app';

  Future<List<UangKeluar>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/uangkeluar');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => UangKeluar.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }

  Future<UangKeluar> createUangKeluar(UangKeluar uangKeluar) async {
    final url = Uri.parse('$_baseUrl/uangkeluaradd');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(uangKeluar.toJson()),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return uangKeluar;
    } else {
      throw Exception('Failed to create Uang Keluar');
    }
  }

  Future<void> updateUangKeluar(UangKeluar uangKeluar) async {
    final url = Uri.parse('$_baseUrl/uangkeluar/${uangKeluar.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(uangKeluar.toJson()),
    );
    print('Update status code: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update Uang Keluar');
    }
  }

  Future<void> deleteUangKeluar(int id) async {
    final url = Uri.parse('$_baseUrl/uangkeluar/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete Uang Keluar');
    }
  }
}