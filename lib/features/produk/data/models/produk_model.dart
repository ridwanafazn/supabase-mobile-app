class ProdukModel {
  final int id;
  final String nama;
  final double harga;
  final String? deskripsi;
  final String userId;
  final DateTime createdAt;

  ProdukModel({
    required this.id,
    required this.nama,
    required this.harga,
    this.deskripsi,
    required this.userId,
    required this.createdAt,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'] as int,
      nama: json['nama'] as String,
      harga: (json['harga'] as num).toDouble(),
      deskripsi: json['deskripsi'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'harga': harga,
      'deskripsi': deskripsi,
    };
  }
}