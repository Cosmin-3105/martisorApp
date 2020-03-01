import 'package:flutter/material.dart';
import 'LoginRegisterPage.dart';
import 'Mapping.dart';
import 'Authentification.dart';
void main(){
  runApp(new BlogApp());
}

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: "SpringView",
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MappingPage(auth: Auth(),),
      //routes: {
      //'/' : (context) =>  MappingPage(auth: Auth(),),
      //'/login':(context) => LoginRegisterPage(),

      // },
    );
  }
}