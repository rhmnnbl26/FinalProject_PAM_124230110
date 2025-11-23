class Bengkel {
  final int? id;
  final String nama;
  final double latitude;
  final double longitude;

  Bengkel({
    this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Bengkel.fromMap(Map<String, dynamic> map) {
    return Bengkel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }
}
