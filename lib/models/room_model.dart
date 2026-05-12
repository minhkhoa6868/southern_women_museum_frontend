class RoomModel {
  final String id;
  final String name;
  final String nameEn;
  final String code;
  final String description;
  final String descriptionEn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.code,
    required this.description,
    required this.descriptionEn,
    this.createdAt,
    this.updatedAt,
  });

  // convert json to RoomModel
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? '').toString(),
      code: (json['code'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      descriptionEn: (json['descriptionEn'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  // convert RoomModel to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'code': code,
      'description': description,
      'descriptionEn': descriptionEn,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
