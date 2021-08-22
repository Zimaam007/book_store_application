import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/create_user.dart';
import 'package:flutter_b2_zimaam/home_screen.dart';
import 'package:flutter_b2_zimaam/shared_preferences_service.dart';
import 'package:flutter_b2_zimaam/show_error_message.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  margin: EdgeInsets.symmetric(vertical:100, horizontal: 30),
                  width: 400,
                  height: 400,
                  /////-----Gradiant Decoration for container-------------
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    /*gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.6),
                        Colors.cyan.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.5,0.7]
                    ),*/
                    borderRadius: BorderRadius.circular(30),
                      ///color: Colors.white
                  ),

                  child: Column(
                    ///mainAxisAlignment: MainAxisAlignment.center,
                    ///crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///////----------Login Text-----------
                      Container(
                        padding: EdgeInsets.only(top: 30),
                        child: Text('Log In',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      ///////----------Email Address-----------
                      Container(
                        width: 350,
                        padding: EdgeInsets.only(left: 20,top: 30,right: 20,bottom: 20),
                        child: Column(
                          children: [
                            Container(
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  icon: Icon(Icons.email_rounded,size: 30,color: Colors.red,),
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
                        width: 350,
                        padding: EdgeInsets.only(left: 20,top: 10,right: 20,bottom: 20),
                        child: Column(
                          children: [
                            Container(
                                child: TextFormField(
                                  controller: _passwordController,
                                  onChanged: (value){},
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.password_rounded,color: Colors.red,),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    labelText: 'Enter Password',
                                    labelStyle: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),

                                  ),
                                )
                            )
                          ],
                        ),
                      ),

                      ///////////-----------Login Button--------
                      Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                          ),
                          child: Text('Log In',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold)
                            ),
                          onPressed: loginButtonClick,
                        ),
                      ),

                      ////////---------Create User Hyperlink------------
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text('Don\'t have an account? ',
                              style: TextStyle(color: Colors.grey,fontSize: 15),),
                            ),
                            Container(
                              child: TextButton(
                                child: Text('CREATE USER',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: createUserButtonClick,
                              ),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              )
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

  void loginButtonClick() async{
    setState(() {
      _isLoading =true;
    });

    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty){
      User? user = await AuthService().loginUser(_emailController.text, _passwordController.text);

      if(user != null){
        print(user.uid);
        await SharedPreferenceService.saveBoolToSharedPreferences('user_logged_in',true);

        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            ModalRoute.withName('/'),
        );
      }else{
        ShowErrorMessage.showMessage(context,'Wrong Email or Password');
      }
    }else{
      ShowErrorMessage.showMessage(context,'Enter valid Email and Password');
    }

    setState(() {
      _isLoading = false;
    });

  }

  void createUserButtonClick() async{
    Navigator.push(context,
    MaterialPageRoute(builder: (builder) => CreateUserScreen()));
  }
}
