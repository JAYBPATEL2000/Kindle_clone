import '../models/book.dart';

/// Temporary asset-based repository. Later, extend to Firebase Storage.
class BookRepository {
  const BookRepository();

  List<Book> getAvailableBooks() {
    return const [
      Book(
        id: 'book_1',
        title: 'Sample Public Domain Book',
        author: 'Author One',
        assetPdfPath: 'assets/pdfs/sample1.pdf',
        coverAssetPath: 'assets/covers/sample1.png',
        isPremium: false,
      ),
      Book(
        id: 'book_2',
        title: 'Premium Book Example',
        author: 'Author Two',
        assetPdfPath: 'assets/pdfs/sample2.pdf',
        coverAssetPath: 'assets/covers/sample2.png',
        isPremium: true,
      ),
    ];
  }
}


