import 'dart:convert';

List<UangMasuk> uangMasukFromJson(String str) => List<UangMasuk>.from(json.decode(str).map((x) => UangMasuk.fromJson(x)));

String uangMasukToJson(List<UangMasuk> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UangMasuk {
    int id;
    String nominal;
    DateTime tanggal;
    String keterangan;

    UangMasuk({
        required this.id,
        required this.nominal,
        required this.tanggal,
        required this.keterangan,
    });

    factory UangMasuk.fromJson(Map<String, dynamic> json) => UangMasuk(
        id: json["id"],
        nominal: json["nominal"],
        tanggal: DateTime.parse(json["tanggal"]),
        keterangan: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nominal": nominal,
        "tanggal": tanggal.toIso8601String(),
        "status": keterangan,
    };
}