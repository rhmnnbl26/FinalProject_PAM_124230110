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
  final double? latitude;
  final double? longitude;
  final String? fotoPath1;
  final String? fotoPath2;
  final String? fotoPath3;
  final String? fotoPath4;
  final String? fotoPath5;
  final String instagramLink;
  final String? kontakOpsional;
  final int? userId; // Pemilik motor

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
    this.latitude,
    this.longitude,
    this.fotoPath1,
    this.fotoPath2,
    this.fotoPath3,
    this.fotoPath4,
    this.fotoPath5,
    required this.instagramLink,
    this.kontakOpsional,
    this.userId,
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
      'latitude': latitude,
      'longitude': longitude,
      'foto_path_1': fotoPath1,
      'foto_path_2': fotoPath2,
      'foto_path_3': fotoPath3,
      'foto_path_4': fotoPath4,
      'foto_path_5': fotoPath5,
      'instagram_link': instagramLink,
      'kontak_opsional': kontakOpsional,
      'user_id': userId,
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
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      fotoPath1: map['foto_path_1'] as String?,
      fotoPath2: map['foto_path_2'] as String?,
      fotoPath3: map['foto_path_3'] as String?,
      fotoPath4: map['foto_path_4'] as String?,
      fotoPath5: map['foto_path_5'] as String?,
      instagramLink: map['instagram_link'] as String,
      kontakOpsional: map['kontak_opsional'] as String?,
      userId: map['user_id'] as int?,
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
