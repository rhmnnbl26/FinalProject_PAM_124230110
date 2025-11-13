class MotorModel {
  final String id;
  final String nama;
  final String merk;
  final int hargaIdr;
  final String kategori;
  final String gambar;
  final String deskripsi;

  MotorModel({
    required this.id,
    required this.nama,
    required this.merk,
    required this.hargaIdr,
    required this.kategori,
    required this.gambar,
    required this.deskripsi,
  });

  factory MotorModel.fromJson(Map<String, dynamic> json) {
    return MotorModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      merk: json['merk'] ?? '',
      hargaIdr: json['harga_idr'] ?? 0,
      kategori: json['kategori'] ?? '',
      gambar: json['gambar'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }
}
