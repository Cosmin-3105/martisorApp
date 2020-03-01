import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'HomePage.dart';
import 'RoundedButton.dart';
import 'constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class UploadPhotoPage extends StatefulWidget{
  State<StatefulWidget> createState(){
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage>{
  File sampleImage;
  String _myValue;
  String url;
  final formKey = new GlobalKey<FormState>();
  bool showSpinner = false;

  Future getImage() async {
    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;

    });
  }

  bool validateAndSave(){
    final form = formKey.currentState;

    if(form.validate()){
      form.save();
      return true;
    }else{
      return false;
    }
  }

  void uploadStatusImage() async {

    if(validateAndSave()){
      setState(() {
        showSpinner = true;
      });
      final StorageReference postImageRef = FirebaseStorage.instance.ref().child("Posteaza Imagini");
      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);

      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = ImageUrl.toString();

      print("umage URL = " + url);

      goToHomePage();
      saveToDatabase(url);
      setState(() {
        showSpinner = false;
      });
    }

  }

  void saveToDatabase(url){
    var dbTimeKey = new DateTime.now();
    var formatDate = new DateFormat('MMM d, yyyy');
    var formatTime = new DateFormat('EEEE, hh:mm aaa');

    String date = formatDate.format(dbTimeKey);
    String time = formatTime.format(dbTimeKey);

    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image": url,
      "description": _myValue,
      "date": date,
      "time": time,
    };

    ref.child("Posts").push().set(data);
  }
  void goToHomePage(){

    //Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context){
        return new HomePage();
      }),);
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: Row(
          children: <Widget>[


            new Text("Incarca o imagine"),
            SizedBox(width: 15,),
            Hero( tag: 'logo', child: Image.asset('images/logo.png', scale: 14,)),
          ],
        ),
        centerTitle: true,
      ),

      body:ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: new Center(
          child: sampleImage == null ? GestureDetector(
            onTap: (){
              getImage();
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                  ),
                  Icon(Icons.add_circle_outline, size: 200, color:Colors.red[300]),
                  Text('Adauga o imagine', style: TextStyle(color: Colors.red[300], fontSize: 20),),
                ],
              ),
            ),
          )

              : enableUpload(),
        ),
      ),









    );
  }

  Widget enableUpload(){
    return new Container(
      child: new Form(
        key: formKey,

        child: Column(
          children: <Widget>
          [
            SizedBox(height: 30,),
            Flexible(child: Image.file(sampleImage, height: 330.0, width: 660.0,)),
            SizedBox(height: 15.0,),

            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TextFormField(
                decoration: kTextFieldDecoration.copyWith(hintText: 'Descriere'),
                validator: (value){
                  return value.isEmpty ? 'Trebuie sa introduci o descriere' : null;
                },
                onSaved: (value){
                  return _myValue = value;
                },
              ),
            ),
            SizedBox(height: 15.0,),

            RoundedButton(
              text: 'Adauga',
              color: Colors.red,
              onPressed: uploadStatusImage,
            ),
          ],
        ),
      ),
    );
  }
}