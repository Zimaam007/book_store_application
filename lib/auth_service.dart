import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  FirebaseAuth auth = FirebaseAuth.instance;

  //////--------Creating User Credentials-------------------------try-catch method----------
  Future<User?> registerUser(String email, String password) async{
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch(e){
      print(e);
    }catch (e){
      print(e);
    }
    return null;
  }

  ///////////-----------Authenticating Login with User Credentials----------------------------
  Future<User?> loginUser(String email, String password) async{
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found'){
        print('No User Found');
      }else if(e.code == 'wrong-password'){
        print('Wrong Password');
      }
      print(e);
    }catch (e){
      print(e);
    }
    return null;
  }

  dynamic getCurrentUserId(){
    return (auth.currentUser != null) ? auth.currentUser!.uid : null;
  }

  Future signOut() async{
    await auth.signOut();
  }
}