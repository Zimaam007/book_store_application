import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/firestore_service.dart';
import 'package:flutter_b2_zimaam/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _authorNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  DocumentSnapshot? _selectedBook;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: Text('Home'),
        ////----------Logout Button-----------
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: logoutButtonClick,
          )
        ],
      ),

      /////------------body-------------------

      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/emil-widlund-ZtI4l8EvyUw-unsplash.jpg"),
                    fit: BoxFit.cover
                )
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(AuthService().getCurrentUserId()).snapshots(),
                builder: (context,snapshot){
                  if(snapshot.hasData){
                    final List<DocumentSnapshot> documents = snapshot.data!.docs;

                    if(documents.isNotEmpty){
                      return ListView(
                          children: documents.map((doc) => _listViewItemContainer(doc)).toList(),
                      );
                    }
                    else{
                      return Center(
                        child: Container(
                          child: Text('No Books'),
                        ),
                      );
                    }
                  }
                  else{
                    return Center(
                      child: Container(
                        child: Text('No Books'),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showBookDetails(context,'add');
        },
        child: Icon(Icons.my_library_add_rounded),
        backgroundColor: Colors.black,
      ),

    );
  }

  Widget _listViewItemContainer(DocumentSnapshot doc){
    return Container(
        height: 70,
        padding: EdgeInsets.only(left: 10,top: 2),
        margin: EdgeInsets.only(left: 5,top: 5,right: 5,bottom: 5),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2
              )
            ]
        ),

        child: ListTile(
          leading: Icon(Icons.library_books_rounded,size: 30),
          title: Text(
            doc['book_name'],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'Author: '+doc['author_name'],
            style: TextStyle(fontSize: 15,color: Colors.black),
          ),

          trailing: Container(
            width: 100,
            child: Wrap(
              alignment: WrapAlignment.end,
              direction: Axis.horizontal,
              children: [
                //////------------Edit / Update Button------------
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 25),
                  onPressed: (){
                    _selectedBook = doc;
                    showBookDetails(context,'update');
                  },
                ),

                ///////-------------Delete Button-----------------
                IconButton(
                  icon: Icon(Icons.delete_rounded,color: Colors.redAccent,size: 25),
                  onPressed: (){
                    CloudFirestoreService().deleteBook(doc.id);
                  },
                )
              ],
            ),
          ),
        )

    );
  }

  /////---------Show book details alert dialog---------
  showBookDetails(BuildContext context, String type){
    bool isUpdateBox = false;

    isUpdateBox = (type != 'update') ? false : true;

    if(isUpdateBox){
      _bookNameController.text = _selectedBook!['book_name'];
      _authorNameController.text = _selectedBook!['author_name'];
      _priceController.text = _selectedBook!['price'];
    }
    ////-----Setting the button------
    ////----Save Button--------------
    Widget saveButton = ElevatedButton(
      child: Text(isUpdateBox? 'Update' : 'Save'),
      onPressed: () async{
        if (_bookNameController.text.isNotEmpty && _authorNameController.text.isNotEmpty && _priceController.text.isNotEmpty){
          if(!isUpdateBox){
            setState(() {
              CloudFirestoreService().addBook(
                  _bookNameController.text,
                  _authorNameController.text,
                  _priceController.text);
            });
          } else{
            setState(() {
              CloudFirestoreService().updateBook(
                  _selectedBook!.id,
                  _bookNameController.text,
                  _authorNameController.text,
                  _priceController.text);
            });
          }
          Navigator.pop(context);
        }
        _emptyTextFields();
      },
    );

    /////---------Cancel Button---------
    Widget cancelButton = ElevatedButton(
      child: Text('Cancel'),
      onPressed: (){
        Navigator.of(context).pop();
        _emptyTextFields();  ///to clear the typed texts
      },
    );

    /////------Setting AddBook Alert box----------
    AlertDialog addBookBox = AlertDialog(
      title: Text(isUpdateBox? 'Update Book Details' : 'Add New Book'),
      content: Container(
        child: Wrap(
          children: <Widget>[
            Container(
              child: TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(
                    labelText: 'Book Name'
                ),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _authorNameController,
                decoration: InputDecoration(
                    labelText: 'Author Name'
                ),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Price'
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        saveButton,
        cancelButton,
      ],
    );

    /////-----Dialog display
    showDialog(context: context,
      builder: (BuildContext context){
        return addBookBox;
      },
    );
  }

  ////------Logout Button function---------
  void logoutButtonClick(){
    print('Logging Out');
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    SystemNavigator.pop();
  }

  /////-----Empty text field function-------
  void _emptyTextFields(){
    _bookNameController.text = '';
    _authorNameController.text = '';
    _priceController.text = '';
  }

}
