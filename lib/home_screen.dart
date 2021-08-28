import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/firestore_service.dart';
import 'package:flutter_b2_zimaam/login_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text('Home'),
        ////----------Logout Button-----------
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded,color: Colors.yellowAccent,),
            onPressed: logoutButtonClick,
          )
        ],
      ),

      /////------------body-------------------

      body: Stack(
        children: [
          ////////----------background image container-----------
          Container(
            alignment: Alignment.center,
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/colorful-books.jpg"),
                    fit: BoxFit.fill,
                )
            ),
          ),

          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
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
                      return welcomeNote();
                    }
                  }
                  else{
                    return Container(
                      child: Center(
                        child: SpinKitChasingDots(color: Colors.grey),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),

      /////----------Floating Add Book button-----------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          showBookDetails(context,'add');
        },
        icon: Icon(Icons.my_library_add_outlined),
        label: Text('ADD BOOK'),
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        elevation: 8,
      ),
    );
  }

  //////-----------Home Screen item containers----------------
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
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  offset: Offset(2,-2)
              )
            ]
        ),

        child: ListTile(
          leading: Icon(Icons.library_books_rounded,size: 30,color: Colors.redAccent,),

          title: Text( doc['book_name'],
            style: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),),

          subtitle: Text( 'Author: '+doc['author_name'],
            style: TextStyle(fontSize: 15,color: Colors.black),),

          ///////-----------Container for Edit and Delete Buttons---------
          trailing: Container(
            width: 100,
            child: Wrap(
              alignment: WrapAlignment.end,
              direction: Axis.horizontal,
              children: [
                //////-----Edit / Update Button (Created for improve user-friendly features)------------
                IconButton(
                  icon: Icon(Icons.edit_rounded, color: Colors.blueAccent, size: 22),
                  onPressed: (){
                    _selectedBook = doc;
                    showBookDetails(context,'update');
                  },
                ),

                ///////-------------Delete Button-----------------
                IconButton(
                  icon: Icon(Icons.delete_rounded,color: Colors.redAccent,size: 22),
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

  /////---------Show book details alert dialog (Used for updating previous entries)---------
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
        else{
           SpinKitChasingDots(color: Colors.grey,size: 50,);
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

    /////------AddBook Alert box----------
    AlertDialog addBookBox = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      title: Text(isUpdateBox? 'Update Book Details' : 'Add New Book'),
      content: Container(
        child: Wrap(
          children: <Widget>[
            Container(
              child: TextFormField(
                controller: _bookNameController,
                decoration: InputDecoration(labelText: 'Book Name'),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _authorNameController,
                decoration: InputDecoration(labelText: 'Author Name'),
              ),
            ),
            Container(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
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

    /////-----Function to display the Add Book alert box------------
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

  //////-----------Welcome Note----------------
  welcomeNote(){
    return Center(
      child: SingleChildScrollView(
        //////-----------White Container---------------
        child: Container(
            margin: EdgeInsets.only(bottom: 55,left: 15,right: 15),
            width: 420,
            height: 500,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30)
            ),

          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  padding:EdgeInsets.only(top: 15,right: 15,left: 15),
                  child: Text('Welcome to Online Book Store !!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(top: 10,left: 20),
                  child: Text('About',
                    style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 5,left: 20,right: 20),
                  child: Text('This ONLINE BOOK STORE mobile application is created to'
                      ' store and maintain the details of Books, and it\'s Author and Price. ',
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(top: 15,left: 20),
                  child: Text('Instructions',
                    style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 5,left: 20,right: 20),
                  child: Text(' * To store a book details, Click the ADD BOOK button, fill the'
                      ' respective fields of book details in \'Add New Book\' box, and click \'Save\' button.',
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 3,left: 20,right: 20),
                  child: Text(' * To edit/update book details, Click the pen icon on the details bar, '
                      'Then you can edit and save it using \'Save\' button.',
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 3,left: 20,right: 20),
                  child: Text(' * To delete a book from the list, Click the delete icon on the details bar, '
                      'Then you can delete the record.',
                    style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Container(
                    padding: EdgeInsets.only(top: 40),
                    alignment: Alignment.center,
                    child: Text('Developed By',
                      style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500),
                    )
                ),

                Container(
                    alignment: Alignment.center,
                    child: Text('ZIMAAM',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700,letterSpacing: 8,color: Colors.indigo),
                    )
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}
