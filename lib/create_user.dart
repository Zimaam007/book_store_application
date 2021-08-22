import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/home_screen.dart';
import 'package:flutter_b2_zimaam/shared_preferences_service.dart';
import 'package:flutter_b2_zimaam/show_error_message.dart';

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
      backgroundColor: Colors.grey,
      //////////-------------App Bar----------
        appBar: AppBar(
          title: Text('Book Store App'),
          backgroundColor: Colors.redAccent,
        ),

        body: Stack(
          children: [
            /////---------Container for Background Image-------------
            Container(
              alignment: Alignment.center,
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/emil-widlund-ZtI4l8EvyUw-unsplash.jpg"),
                      fit: BoxFit.cover
                  )
              ),
                ////////----------Login Box Decoration---------------
                child: SingleChildScrollView(
                    child:Container(
                      margin: EdgeInsets.symmetric( vertical: 20,horizontal: 30),
                      width: 400,
                      height: 550,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)
                      ),
                      child: Container(
                        child: Column(

                          children: [
                            ///////----------Create User Text-----------
                            Container(
                              padding: EdgeInsets.only(top: 30,bottom: 10),
                              child: Text('Create User',
                                style: TextStyle(
                                    color: Colors.brown,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold
                                ),),
                            ),

                            ///////----------Container for Email Address----------
                            Container(
                              child: Column(
                                children: [
                                  Container(
                                    ////padding: EdgeInsets.only(left: 20, bottom: 10),
                                    child: Text('Email',
                                      textAlign: TextAlign.left,
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
                                  Container(
                                    child: Text('Password',
                                      textAlign: TextAlign.left,
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
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          labelText: 'Enter Password',
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
                                  Container(
                                    child: Text('Confirm Password',
                                      textAlign: TextAlign.left,
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
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          labelText: 'Retype Password',
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),

                            ///////////-----------Create User Button--------
                            Container(
                              child: RaisedButton(
                                color: Colors.grey,
                                elevation: 10,
                                child: Text('Create User',style: TextStyle(color: Colors.white),),
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
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ))
          ],
        )

    );
  }

  void createUserButtonClick() async{
    setState(() {
      _isLoading = true;
    });

    if(_emailController.text.isNotEmpty && (_passwordController.text.isNotEmpty == _retypePasswordController.text.isNotEmpty)  ){
      User? user = await AuthService().registerUser(_emailController.text, _passwordController.text);

      if(user != null){
        print(user.uid);
        await SharedPreferenceService.saveBoolToSharedPreferences('user_logged_in', true);

        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context)=> HomeScreen()),
            ModalRoute.withName('/'),
        );
      }
    }
    else{
      ShowErrorMessage.showMessage(context, 'Enter valid email & Check both Passwords are same');
    }

    setState(() {
      _isLoading = false;
    });

  }
}
