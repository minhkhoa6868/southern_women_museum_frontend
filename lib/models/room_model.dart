class RoomModel {
  final String id;
  final String name;
  final String nameEn;
  final String code;
  final String description;
  final String descriptionEn;

  RoomModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.code,
    required this.description,
    required this.descriptionEn,
  });

  // convert json to RoomModel
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      descriptionEn: json['descriptionEn'] as String,
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
    };
  }
}