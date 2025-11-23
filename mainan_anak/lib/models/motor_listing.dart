class MotorListing {
  final int? id;
  final String nama;
  final String brand;
  final int cc;
  final int tahun;
  final double hargaIdr;
  final int kilometer;
  final String kondisi; // 'baru' atau 'bekas'
  final String deskripsi;
  final String lokasi;
  final String? fotoPath1;
  final String? fotoPath2;
  final String? fotoPath3;
  final String? fotoPath4;
  final String? fotoPath5;
  final String instagramLink;
  final String? kontakOpsional;

  MotorListing({
    this.id,
    required this.nama,
    required this.brand,
    required this.cc,
    required this.tahun,
    required this.hargaIdr,
    required this.kilometer,
    required this.kondisi,
    required this.deskripsi,
    required this.lokasi,
    this.fotoPath1,
    this.fotoPath2,
    this.fotoPath3,
    this.fotoPath4,
    this.fotoPath5,
    required this.instagramLink,
    this.kontakOpsional,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'brand': brand,
      'cc': cc,
      'tahun': tahun,
      'harga_idr': hargaIdr,
      'kilometer': kilometer,
      'kondisi': kondisi,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'foto_path_1': fotoPath1,
      'foto_path_2': fotoPath2,
      'foto_path_3': fotoPath3,
      'foto_path_4': fotoPath4,
      'foto_path_5': fotoPath5,
      'instagram_link': instagramLink,
      'kontak_opsional': kontakOpsional,
    };
  }

  factory MotorListing.fromMap(Map<String, dynamic> map) {
    return MotorListing(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      brand: map['brand'] as String,
      cc: map['cc'] as int,
      tahun: map['tahun'] as int,
      hargaIdr: (map['harga_idr'] as num).toDouble(),
      kilometer: map['kilometer'] as int,
      kondisi: map['kondisi'] as String,
      deskripsi: map['deskripsi'] as String,
      lokasi: map['lokasi'] as String,
      fotoPath1: map['foto_path_1'] as String?,
      fotoPath2: map['foto_path_2'] as String?,
      fotoPath3: map['foto_path_3'] as String?,
      fotoPath4: map['foto_path_4'] as String?,
      fotoPath5: map['foto_path_5'] as String?,
      instagramLink: map['instagram_link'] as String,
      kontakOpsional: map['kontak_opsional'] as String?,
    );
  }

  List<String> get allPhotos {
    return [
      if (fotoPath1 != null) fotoPath1!,
      if (fotoPath2 != null) fotoPath2!,
      if (fotoPath3 != null) fotoPath3!,
      if (fotoPath4 != null) fotoPath4!,
      if (fotoPath5 != null) fotoPath5!,
    ];
  }
}
