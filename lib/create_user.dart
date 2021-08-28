import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/home_screen.dart';
import 'package:flutter_b2_zimaam/shared_preferences_service.dart';
import 'package:flutter_b2_zimaam/show_error_message.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _retypePasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //////////-------------App Bar----------
        appBar: AppBar(
          centerTitle: true,
          title: Text('Book Store App'),
          backgroundColor: Colors.blueAccent,
        ),

        body: Stack(
          children: [
            /////---------Container for Background Image-------------
            Container(
              alignment: Alignment.center,
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/colorful-books.jpg"),
                      fit: BoxFit.cover
                  )
              ),

                ////////----------User Creating Box Decoration---------------
                child: SingleChildScrollView(
                    child:Container(
                      margin: EdgeInsets.symmetric( horizontal: 30),
                      width: 400,
                      height: 520,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent.withOpacity(0.4),
                                Colors.white30.withOpacity(0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              stops: [0.2,0.6]
                          ),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ///////----------Create User Text-----------
                            Container(
                              child: Text('Create User',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold
                                ),),
                            ),

                            ///////----------Container for Email Address----------
                            Container(
                              child: Column(
                                children: [
                                  /////----------Container for Text-------
                                  Container(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Text('Email',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),
                                  Container(
                                    width: 350,
                                    padding: EdgeInsets.only(left: 20,top: 5,right: 20,bottom: 20),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        labelText: 'Enter Email Address',
                                        labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            ///////////-----------Password----------------
                            Container(
                              child: Column(
                                children: [
                                  /////---------Container for Text------------
                                  Container(
                                    child: Text('Password',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),
                                  Container(
                                      width: 350,
                                      padding: EdgeInsets.only(left: 20,top: 5,right: 20,bottom: 20),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        onChanged: (value){},
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          labelText: 'Enter Password',
                                          labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),

                            ///////////-----------Retype Password----------------
                            Container(
                              child: Column(
                                children: [
                                  //////---------Container for Text------------
                                  Container(
                                    child: Text('Confirm Password',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),
                                  Container(
                                      width: 350,
                                      padding: EdgeInsets.only(left: 20,top: 5,right: 20,bottom: 20),
                                      child: TextFormField(
                                        controller: _retypePasswordController,
                                        onChanged: (value){},
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          labelText: 'Retype Password',
                                          labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),

                            ///////////-----------Create User Button--------
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              width: 200,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                                ),
                                child: Text('Create User',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: createUserButtonClick,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ),
            ),

            Visibility(
                visible: _isLoading,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: SpinKitChasingDots(
                      color: Colors.white,
                      size: 50,
                      duration: Duration(seconds: 2),
                    ),
                  ),
                )
            )
          ],
        )
    );
  }

  void createUserButtonClick() async{

    if(EmailValidator.validate(_emailController.text)==false) {
      ShowErrorMessage.showMessage(context, 'Enter a valid email address');
      _isLoading=false;
      return;
    }

    if(_passwordController.text.isEmpty || _passwordController.text.length<6) {
      ShowErrorMessage.showMessage(context, 'Password is required and must at least 6 characters long');
      _isLoading=false;
      return;
    }

    if(_retypePasswordController.text.isEmpty || _passwordController.text.length < 6) {
      ShowErrorMessage.showMessage(context, 'Confirm password is required and must at least 6 characters long');
      _isLoading=false;
      return;
    }

    if(_passwordController.text != _retypePasswordController.text) {
      ShowErrorMessage.showMessage(context, 'Password and confirm password does not match');
      _isLoading=false;
      return;
    }

    setState(() {
      _isLoading = true;
    });

    User? user = await AuthService().registerUser(_emailController.text, _passwordController.text);

    if(user != null){
      print(user.uid);
      await SharedPreferenceService.saveBoolToSharedPreferences('user_logged_in', true);

      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context)=> HomeScreen()),
          ModalRoute.withName('/'),
      );
    }

    setState(() {
      _isLoading = false;
    });

  }
}
