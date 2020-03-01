import 'package:flutter/material.dart';

class DialogBox{

  information(BuildContext context, String title, String desctiption){
    return showDialog(context: 
      context,
      barrierDismissible: true,

      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(desctiption)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: (){
                return Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }
}