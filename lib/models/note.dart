class Note {
  final int? id;
  final String title;
  final String body;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    int? id,
    String? title,
    String? body,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'tags': tags.join(','),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    final rawTags = map['tags'] as String? ?? '';
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      tags: rawTags.isEmpty ? [] : rawTags.split(','),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}
