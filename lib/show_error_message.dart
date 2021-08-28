import 'package:flutter/material.dart';

class ShowErrorMessage{
  static void showMessage(BuildContext context, String message){
    ElevatedButton okButton = ElevatedButton(
        child: Text('OK'),
        onPressed: (){
          Navigator.pop(context);
        },
      style: ElevatedButton.styleFrom(
        primary: Colors.teal
      ),
    );


    AlertDialog errorMessageAlert = AlertDialog(
      title: Text('Error'),
      content: Container(
        child: Text(message),
      ),
      actions: [
        okButton
      ],
    );

    ////////------------Show Dialog Box-----------
    showDialog(
        context: context,
        builder: (BuildContext context){
          return errorMessageAlert;
        },
    );
  }
}