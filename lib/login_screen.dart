import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_b2_zimaam/auth_service.dart';
import 'package:flutter_b2_zimaam/create_user.dart';
import 'package:flutter_b2_zimaam/home_screen.dart';
import 'package:flutter_b2_zimaam/shared_preferences_service.dart';
import 'package:flutter_b2_zimaam/show_error_message.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


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
                  fit: BoxFit.fill
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
                    ///color: Colors.white.withOpacity(1),
                    gradient: LinearGradient(
                      colors: [
                        ///Colors.yellowAccent.withOpacity(0.7),
                        ///Colors.lightGreen.withOpacity(0.7),
                        Colors.blueAccent.withOpacity(0.4),
                        Colors.white30.withOpacity(0.7),

                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      stops: [0.2,0.6]
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ///////----------Login Text-----------
                      Container(
                        child: Text('Login',
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
                                  icon: Icon(Icons.email_rounded,size: 30,color: Colors.deepOrangeAccent,),
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
                                    icon: Icon(Icons.vpn_key_rounded,size: 30,color: Colors.deepOrangeAccent,),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    labelText: 'Enter Password',
                                    labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                                  ),
                                )
                            )
                          ],
                        ),
                      ),

                      ///////////-----------Login Button--------
                      Container(
                        width: 180,
                        margin: EdgeInsets.only(left: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))
                          ),
                          child: Text('Login',
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
                              style: TextStyle(color: Colors.black54,fontSize: 15),),
                            ),
                            Container(
                              child: TextButton(
                                child: Text('CREATE USER',
                                  style: TextStyle(
                                      color: Colors.indigo,
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
                  child: SpinKitChasingDots(
                    color: Colors.white,
                    size: 50,
                    duration: Duration(seconds: 1),
                  ),
                ),
              )
          )
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
