import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';

class CloudFirestoreService{
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool addBook(String bookName,String authorName, String price){
    Map<String, dynamic> bookData = {
      'book_name' : bookName,
      'author_name' : authorName,
      'price' : price
    };

    try{
      if(AuthService().getCurrentUserId() != null){
        CollectionReference collectionReference = firestore.collection(AuthService().getCurrentUserId());
        collectionReference.add(bookData);
        return true;
      }
    } on FirebaseException catch(e){
      print(e.message);
    }
    return false;
  }

  bool updateBook(String documentId, String bookName, String authorName, String price){
    Map<String, dynamic> bookData = {
      'book_name' : bookName,
      'author_name' : authorName,
      'price' : price
    };

    try{
      if(AuthService().getCurrentUserId() != null){
        CollectionReference collectionReference = firestore.collection(AuthService().getCurrentUserId());
        collectionReference.doc(documentId).update(bookData);
        return true;
      }
    } on FirebaseException catch(e){
      print(e.message);
    }
    return false;
  }

  bool deleteBook(String documentId){
    try{
      firestore.collection(AuthService().getCurrentUserId()).doc(documentId).delete();
      return false;
    } on FirebaseException catch(e){
      print(e.message);
    }
    return false;
  }
}