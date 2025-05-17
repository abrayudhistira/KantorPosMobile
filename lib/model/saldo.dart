class Saldo {
    Saldo({
        required this.id,
        required this.nominalakhir,
        required this.tanggalperubahan,
    });

    final int? id;
    final String? nominalakhir;
    final DateTime? tanggalperubahan;

    factory Saldo.fromJson(Map<String, dynamic> json){ 
        return Saldo(
            id: json["id"],
            nominalakhir: json["nominalakhir"],
            tanggalperubahan: DateTime.tryParse(json["tanggalperubahan"] ?? ""),
        );
    }

}
