class Habit {
  String id;
  String title;
  String description;
  DateTime createdDate;
  Map<String, bool> history; // {"2025-06-01": true}

  Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    required this.history,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "createdDate": createdDate.toIso8601String(),
        "history": history,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        createdDate: DateTime.parse(json["createdDate"]),
        history: Map<String, bool>.from(json["history"]),
      );
}