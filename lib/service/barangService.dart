import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kantorpos/model/barang.dart';

class BarangService {
  static const _baseUrl = 'https://14a4-139-192-222-221.ngrok-free.app';

  Future<List<Barang>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/barang');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }

  Future<Barang> createBarang(Barang barang) async {
    final url = Uri.parse('$_baseUrl/barangadd');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barang.toJson()),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Jika backend tidak mengembalikan data barang, cukup return barang yang dikirim
      return barang;
    } else {
      throw Exception('Failed to create barang');
    }
  }

  Future<void> updateBarang(Barang barang) async {
    final url = Uri.parse('$_baseUrl/barang/${barang.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(barang.toJson()),
    );

     print('Update status code: ${response.statusCode}');
    print('Update response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update barang');
    }
  }

  Future<void> deleteBarang(String id) async {
    final url = Uri.parse('$_baseUrl/barang/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete barang');
    }
  }
}