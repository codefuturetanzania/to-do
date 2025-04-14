class Task {
  int? id;
  String title;
  String? description;
  String? category;
  bool isDone;

  Task({
    this.id,
    required this.title,
    this.description,
    this.category,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isDone': isDone ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      isDone: map['isDone'] == 1,
    );
  }
}
