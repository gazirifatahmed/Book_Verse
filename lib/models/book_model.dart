class Book {
  final String id;
  final String title;
  final String author;
  final String coverAsset;
  final String description;
  final String contentPath;
  final double rating;
  final int pages;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverAsset,
    required this.description,
    required this.contentPath,
    required this.rating,
    required this.pages,
  });
}