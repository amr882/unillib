import 'package:cloud_firestore/cloud_firestore.dart';

class BookLocation {
  final String building;
  final String floor;
  final String shelf;

  BookLocation({
    required this.building,
    required this.floor,
    required this.shelf,
  });

  factory BookLocation.fromMap(Map<String, dynamic> map) {
    return BookLocation(
      building: map['building'] as String? ?? '??',
      floor: map['floor'] as String? ?? '??',
      shelf: map['shelf'] as String? ?? '??',
    );
  }

  Map<String, dynamic> toMap() {
    return {'building': building, 'floor': floor, 'shelf': shelf};
  }

  @override
  String toString() =>
      'BookLocation(building: $building, floor: $floor, shelf: $shelf)';
}

class Book {
  final String id;
  final String rawId;
  final String title;
  final String titleLower;
  final String author;
  final String authorLower;
  final String description;
  final String isbn;
  final String year;
  final String language;
  final String category;
  final String faculty;
  final String facultySlug;
  final String coverUrl;
  final String sourceUrl;
  final String createdAt;
  final String updatedAt;
  final int availableCopies;
  final int totalCopies;
  final int borrowCount;
  final bool isAvailable;
  final List<String> tags;
  final List<dynamic> reservedBy;
  final List<dynamic> borrowedBy;
  final BookLocation location;

  Book({
    required this.id,
    required this.rawId,
    required this.title,
    required this.titleLower,
    required this.author,
    required this.authorLower,
    required this.description,
    required this.isbn,
    required this.year,
    required this.language,
    required this.category,
    required this.faculty,
    required this.facultySlug,
    required this.coverUrl,
    required this.sourceUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.availableCopies,
    required this.totalCopies,
    required this.borrowCount,
    required this.isAvailable,
    required this.tags,
    required this.reservedBy,
    required this.borrowedBy,
    required this.location,
  });

  bool get hasCover =>
      coverUrl.isNotEmpty &&
      coverUrl != '??' &&
      coverUrl != "NO_IMAGE_PLACEHOLDER";

  factory Book.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Book.fromMap(data);
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: (map['id'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['id'] as String,
      rawId: (map['raw_id'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['raw_id'] as String,
      title: (map['title'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['title'] as String,
      titleLower: (map['title_lower'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['title_lower'] as String,
      author: (map['author'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['author'] as String,
      authorLower: (map['author_lower'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['author_lower'] as String,
      description: (map['description'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['description'] as String,
      isbn: (map['isbn'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['isbn'] as String,
      year: (map['year'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['year'] as String,
      language: (map['language'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['language'] as String,
      category: (map['category'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['category'] as String,
      faculty: (map['faculty'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['faculty'] as String,
      facultySlug: (map['faculty_slug'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['faculty_slug'] as String,
      coverUrl: (map['cover_url'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['cover_url'] as String,
      sourceUrl: (map['source_url'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['source_url'] as String,
      createdAt: (map['created_at'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['created_at'] as String,
      updatedAt: (map['updated_at'] as String?)?.trim().isEmpty ?? true
          ? '??'
          : map['updated_at'] as String,
      availableCopies: (map['available_copies'] as num?)?.toInt() ?? 0,
      totalCopies: (map['total_copies'] as num?)?.toInt() ?? 0,
      borrowCount: (map['borrow_count'] as num?)?.toInt() ?? 0,
      isAvailable: map['is_available'] as bool? ?? false,
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      reservedBy: map['reserved_by'] as List<dynamic>? ?? [],
      borrowedBy: map['borrowed_by'] as List<dynamic>? ?? [],
      location: map['location'] != null
          ? BookLocation.fromMap(
              Map<String, dynamic>.from(map['location'] as Map),
            )
          : BookLocation(building: '??', floor: '??', shelf: '??'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'raw_id': rawId,
      'title': title,
      'title_lower': titleLower,
      'author': author,
      'author_lower': authorLower,
      'description': description,
      'isbn': isbn,
      'year': year,
      'language': language,
      'category': category,
      'faculty': faculty,
      'faculty_slug': facultySlug,
      'cover_url': coverUrl,
      'source_url': sourceUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'available_copies': availableCopies,
      'total_copies': totalCopies,
      'borrow_count': borrowCount,
      'is_available': isAvailable,
      'tags': tags,
      'reserved_by': reservedBy,
      'borrowed_by': borrowedBy,
      'location': location.toMap(),
    };
  }

  Book copyWith({
    String? id,
    String? rawId,
    String? title,
    String? titleLower,
    String? author,
    String? authorLower,
    String? description,
    String? isbn,
    String? year,
    String? language,
    String? category,
    String? faculty,
    String? facultySlug,
    String? coverUrl,
    String? sourceUrl,
    String? createdAt,
    String? updatedAt,
    int? availableCopies,
    int? totalCopies,
    int? borrowCount,
    bool? isAvailable,
    List<String>? tags,
    List<dynamic>? reservedBy,
    List<dynamic>? borrowedBy,
    BookLocation? location,
  }) {
    return Book(
      id: id ?? this.id,
      rawId: rawId ?? this.rawId,
      title: title ?? this.title,
      titleLower: titleLower ?? this.titleLower,
      author: author ?? this.author,
      authorLower: authorLower ?? this.authorLower,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      year: year ?? this.year,
      language: language ?? this.language,
      category: category ?? this.category,
      faculty: faculty ?? this.faculty,
      facultySlug: facultySlug ?? this.facultySlug,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      availableCopies: availableCopies ?? this.availableCopies,
      totalCopies: totalCopies ?? this.totalCopies,
      borrowCount: borrowCount ?? this.borrowCount,
      isAvailable: isAvailable ?? this.isAvailable,
      tags: tags ?? this.tags,
      reservedBy: reservedBy ?? this.reservedBy,
      borrowedBy: borrowedBy ?? this.borrowedBy,
      location: location ?? this.location,
    );
  }

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Book && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
