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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      imageUrl: json['image_url'],
      status: json['status'],
    );
  }

  String? get formattedDate => null;
}