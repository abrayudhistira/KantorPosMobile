import 'dart:convert';

List<UangKeluar> uangKeluarFromJson(String str) => List<UangKeluar>.from(json.decode(str).map((x) => UangKeluar.fromJson(x)));

String uangKeluarToJson(List<UangKeluar> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UangKeluar {
    int id;
    String nominalkeluar;
    DateTime tanggalkeluar;
    String tujuan;
    String keterangan;

    UangKeluar({
        required this.id,
        required this.nominalkeluar,
        required this.tanggalkeluar,
        required this.tujuan,
        required this.keterangan,
    });

    factory UangKeluar.fromJson(Map<String, dynamic> json) => UangKeluar(
        id: json["id"],
        nominalkeluar: json["nominalkeluar"],
        tanggalkeluar: DateTime.parse(json["tanggalkeluar"]),
        tujuan: json["tujuan"],
        keterangan: json["keterangan"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nominalkeluar": nominalkeluar,
        "tanggalkeluar": tanggalkeluar.toIso8601String(),
        "tujuan": tujuan,
        "keterangan": keterangan,
    };
}