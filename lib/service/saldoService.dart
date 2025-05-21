import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kantorpos/model/saldo.dart';
// Ensure that the file 'lib/model/saldo.dart' exists and contains a class named 'Saldo'

class SaldoService {
  static const _saldoUrl = 'https://8f60-2405-5fc0-7-1-3c0d-e012-e09c-8c2a.ngrok-free.app';

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