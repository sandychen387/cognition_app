// lib/models/book_model.dart

class Book {
  final String id;
  final String title;
  final String? author;
  final String? coverUrl;
  final String? summary;
  final List<String>? coreQuotes;
  final List<String>? tags;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.coverUrl,
    this.summary,
    this.coreQuotes,
    this.tags,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      coverUrl: json['cover_url'],
      summary: json['summary'],
      coreQuotes: json['core_quotes'] != null 
          ? List<String>.from(json['core_quotes']) 
          : null,
      tags: json['tags'] != null 
          ? List<String>.from(json['tags']) 
          : null,
    );
  }
}