import 'dart:convert';

class Ruangan {
  int id;
  String nama_ruangan;
  String keterangan;
  String created_at;
  String updated_at;
  String kapasitas;

  Ruangan(
      {this.id = 0,
      required this.nama_ruangan,
      required this.keterangan,
      required this.kapasitas,
      required this.created_at,
      required this.updated_at});

  factory Ruangan.fromJson(Map<String, dynamic> map) {
    return Ruangan(
        id: map["id"],
        nama_ruangan: map["nama_ruangan"],
        keterangan: map["keterangan"],
        kapasitas: map["kapasitas"],
        created_at: map["created_at"],
        updated_at: map["updated_at"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nama_ruangan": nama_ruangan,
      "keterangan": keterangan,
      "kapasitas": kapasitas,
      "created_at": created_at,
      "updated_at": updated_at
    };
  }

  @override
  String toString() {
    return 'Ruangan{id: $id, nama_ruangan: $nama_ruangan, keterangan: $keterangan, keterangan: $keterangan, created_at: $created_at, "updated_at": $updated_at }';
  }
}

List<Ruangan> ruanganFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<Ruangan>.from(data.map((item) => Ruangan.fromJson(item)));
}

String ruanganToJson(Ruangan data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
