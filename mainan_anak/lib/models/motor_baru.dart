class MotorBaru {
  final String id;
  final String nama;
  final String merk;
  final double hargaIdr;
  final String kategori;
  final String gambar;
  final String deskripsi;

  MotorBaru({
    required this.id,
    required this.nama,
    required this.merk,
    required this.hargaIdr,
    required this.kategori,
    required this.gambar,
    required this.deskripsi,
  });

  factory MotorBaru.fromJson(Map<String, dynamic> json) {
    return MotorBaru(
      id: json['id'].toString(),
      nama: json['nama'] as String? ?? '',
      merk: json['merk'] as String? ?? '',
      hargaIdr: (json['harga_idr'] as num?)?.toDouble() ?? 0.0,
      kategori: json['kategori'] as String? ?? '',
      gambar: json['gambar'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'merk': merk,
      'harga_idr': hargaIdr,
      'kategori': kategori,
      'gambar': gambar,
      'deskripsi': deskripsi,
    };
  }
}
