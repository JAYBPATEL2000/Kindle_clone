import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _repository;
  List<Book> _books = const [];

  BookProvider({BookRepository? repository}) : _repository = repository ?? const BookRepository() {
    _books = _repository.getAvailableBooks();
  }

  List<Book> get books => _books;
}


