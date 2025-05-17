import 'dart:convert';

import 'package:intl/intl.dart';

List<UangMasuk> uangMasukFromJson(String str) =>
    List<UangMasuk>.from(json.decode(str).map((x) => UangMasuk.fromJson(x)));

String uangMasukToJson(List<UangMasuk> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UangMasuk {
  UangMasuk({
    required this.id,
    required this.nominal,
    required this.tanggal,
    required this.keterangan,
  });

  final int id;
  final String nominal;
  final DateTime tanggal;
  final String keterangan;

  factory UangMasuk.fromJson(Map<String, dynamic> json) {
    return UangMasuk(
      id: json["id"] is int 
          ? json["id"] 
          : int.tryParse(json["id"]?.toString() ?? '0') ?? 0,
      nominal: json["nominal"]?.toString() ?? '0',
      tanggal: DateTime.tryParse(json["tanggal"]?.toString() ?? '') 
          ?? DateTime.now(),
      keterangan: json["keterangan"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nominal": nominal,
        "tanggal": DateFormat('yyyy-MM-dd').format(tanggal),
        "keterangan": keterangan,
      };
}
