import 'package:flutter/foundation.dart';

@immutable
class Event {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? category;
  final String? location;
  final DateTime eventDate;
  final String? thumbnailUrl;
  final String? imageUrl;
  final int? capacity;
  final int attendeesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.category,
    this.location,
    required this.eventDate,
    this.thumbnailUrl,
    this.imageUrl,
    this.capacity,
    this.attendeesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      location: json['location'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
      imageUrl: json['image_url'] as String?,
      capacity: json['capacity'] as int?,
      attendeesCount: json['attendees_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'category': category,
    'location': location,
    'event_date': eventDate.toIso8601String(),
    'thumbnail_url': thumbnailUrl,
    'image_url': imageUrl,
    'capacity': capacity,
    'attendees_count': attendeesCount,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Event copyWith({
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? eventDate,
    String? thumbnailUrl,
    String? imageUrl,
    int? capacity,
  }) {
    return Event(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      capacity: capacity ?? this.capacity,
      attendeesCount: attendeesCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
