import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kantorpos/model/saldo.dart';
// Ensure that the file 'lib/model/saldo.dart' exists and contains a class named 'Saldo'

class SaldoService {
  static const _saldoUrl = 'https://14a4-139-192-222-221.ngrok-free.app';

  Future<List<Saldo>> fetchAll() async {
    final uri = Uri.parse('$_saldoUrl/saldo');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => Saldo.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }
  
}