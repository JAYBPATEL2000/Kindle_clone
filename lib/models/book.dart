class Book {
  final String id;
  final String title;
  final String author;
  final String assetPdfPath; // e.g., assets/pdfs/book1.pdf
  final String coverAssetPath; // e.g., assets/covers/book1.png
  final bool isPremium;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.assetPdfPath,
    required this.coverAssetPath,
    this.isPremium = false,
  });
}


