import 'dart:convert';
import 'package:intl/intl.dart';

List<Barang> barangFromJson(String str) => List<Barang>.from(json.decode(str).map((x) => Barang.fromJson(x)));

String barangToJson(List<Barang> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
String formatTanggal(DateTime date) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
}

class Barang {
    int id;
    String namaBarang;
    String jenisBarang;
    DateTime tanggalMasuk;
    String asalbarang;
    String namaasalbarang;
    String foto;

    Barang({
        required this.id,
        required this.namaBarang,
        required this.jenisBarang,
        required this.tanggalMasuk,
        required this.asalbarang,
        required this.namaasalbarang,
        required this.foto,
    });

    factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        id: json["id"],
        namaBarang: json["nama_barang"],
        jenisBarang: json["jenis_barang"],
        tanggalMasuk: DateTime.parse(json["tanggal_masuk"]),
        asalbarang: json["asalbarang"],
        namaasalbarang: json["namaasalbarang"],
        foto: json["foto"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nama_barang": namaBarang,
        "jenis_barang": jenisBarang,
        "tanggal_masuk": DateFormat('yyyy-MM-dd HH:mm:ss').format(tanggalMasuk),
        "asalbarang": asalbarang,
        "namaasalbarang": namaasalbarang,
        "foto": foto,
    };
}