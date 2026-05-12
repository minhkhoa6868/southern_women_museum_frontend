import 'package:intl/intl.dart';

class Artifact {
  const Artifact({
    required this.id,
    required this.roomId,
    this.roomName,
    required this.name,
    required this.description,
    required this.descriptionEn,
    required this.orderNo,
    this.imgUrl,
    required this.positionX,
    required this.positionY,
    this.historyDate,
  });

  final String id;
  final String roomId;
  final String? roomName;
  final String name;
  final String description;
  final String descriptionEn;
  final int orderNo;
  final String? imgUrl;
  final double positionX;
  final double positionY;
  final DateTime? historyDate;

  factory Artifact.fromJson(Map<String, dynamic> json) {
    DateTime? historyDate;
    final raw = json['history_date'] ?? json['historyDate'];
    if (raw != null) {
      try {
        historyDate = DateTime.parse(raw.toString());
      } catch (_) {}
    }

    return Artifact(
      id: (json['id'] ?? '').toString(),
      roomId: (json['room_id'] ?? json['roomId'] ?? '').toString(),
      roomName: (json['room_name'] ?? json['roomName'])?.toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      descriptionEn: (json['description_en'] ?? json['descriptionEn'] ?? '')
          .toString(),
      orderNo: ((json['order_no'] ?? json['orderNo'] ?? 0) as num).toInt(),
      imgUrl: (json['img_url'] ?? json['imgUrl'])?.toString(),
      positionX: ((json['position_x'] ?? json['positionX'] ?? 0.5) as num)
          .toDouble(),
      positionY: ((json['position_y'] ?? json['positionY'] ?? 0.5) as num)
          .toDouble(),
      historyDate: historyDate,
    );
  }

  String get formattedDate {
    if (historyDate == null) return '';
    return DateFormat('dd/MM/yyyy').format(historyDate!);
  }
}
