import 'package:intl/intl.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String? imageUrl;
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  String get formattedDate {
    if (date.isEmpty) return '';
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      return date;
    }
  }
}