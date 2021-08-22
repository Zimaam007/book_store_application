class Book{
  int? id;
  String? bookName;
  String? authorName;
  String? price;

  Book({this.id, this.bookName, this.authorName, this.price});

  @override
  //////-----From Map-----Map ==> Book Objects--------
  static Book fromMap(Map<String,dynamic> query){
    Book book = Book();
    book.id = query['id'];
    book.bookName = query['book_name'];
    book.authorName = query['author_name'];
    book.price = query['price'];
    return book;
  }

  @override
  //////------To Map ----- Book ==> Map--------
  static Map<String,dynamic> toMap(Book book){
    return<String,dynamic>{
      'id' : book.id,
      'book_name' : book.bookName,
      'author_name' : book.authorName,
      'price' : book.price
    };
  }

  @override
  //////-----From Map List-----Map List ==> Book List--------
  static List<Book> fromList(List<Map<String,dynamic>> query){
    List<Book> books = [];
    for(Map<String,dynamic> map in query){
      books.add(fromMap(map));
    }
    return books;
  }
}