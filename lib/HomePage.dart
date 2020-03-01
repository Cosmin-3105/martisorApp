import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:social_app/Authentification.dart';
import 'package:social_app/PhotoUpload.dart';
import 'Posts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//import 'package:http/http.dart' as http;
//import 'package:image_picker_saver/image_picker_saver.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget{

  HomePage({
    this.auth,
    this.onSignedOut,
  });

  final AuthImplementaion auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState(){
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{

  bool showSpinner1 = false;
  List<Posts> postsList = [];

  @override
  void initState() {
    super.initState();

    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("Posts");
    postsRef.once().then((DataSnapshot snap){
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postsList.clear();

      for(var individualKey in KEYS){
        Posts posts = new Posts(
          DATA[individualKey]['image'],
          DATA[individualKey]['description'],
          DATA[individualKey]['date'],
          DATA[individualKey]['time'],
        );
        postsList.add(posts);
      }
      setState(() {
        print('length : $postsList');
      });

    });


  }

  void _logoutUser() async{
    try{
      await widget.auth.signOut();
      widget.onSignedOut();
    }catch(e){
      print(e.toString());
    }

  }

  @override
  Widget  build(BuildContext context){
    return Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: <Widget>[
            Hero( tag: 'logo', child: Image.asset('images/logo.png', scale: 14,)),
            SizedBox(width: 15,),
            new Text("Martisoare"),
            Expanded(
              child: Container(
                color: Colors.red,
              ),
            ),
            new IconButton(
              icon: new Icon(Icons.add_photo_alternate),
              iconSize: 30,
              color: Colors.white,
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context){
                    return new UploadPhotoPage();
                  }),
                );
              },
            ),
          ],

        ),
        centerTitle: true,
      ),

      body: ModalProgressHUD(
        inAsyncCall: showSpinner1,
        child: new Container(
          child: postsList.length == 0 ?  SpinKitFadingCircle(
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.red : Colors.green,
                ),
              );
            },
          ): new ListView.builder(
            itemCount: postsList.length,
            itemBuilder: (_, index){
              return PostsUI(postsList[index].image,postsList[index].description,postsList[index].date,postsList[index].time);
            },
          ),
        ),
      ),


     /* keytool -list -v -keystore "C:\Users\asusrog\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android*/

//      bottomNavigationBar: new BottomAppBar(
//        color: Colors.green,
//        child: new Container(
//          margin: const EdgeInsets.only(left: 70.0, right: 70.0),
//
//          child: new Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            mainAxisSize: MainAxisSize.max,
//
//            children: <Widget>[
//              new IconButton(
//                icon: new Icon(Icons.exit_to_app),
//                iconSize: 45,
//                color: Colors.white,
//                onPressed: _logoutUser,
//              ),
//              new IconButton(
//                icon: new Icon(Icons.add_photo_alternate),
//                iconSize: 45,
//                color: Colors.white,
//                onPressed: (){
//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(builder: (context){
//                      return new UploadPhotoPage();
//                    }),
//                  );
//                },
//              ),
//            ],
//          ),
//        ),
//      ),
    );    

  }



  Widget PostsUI(String image, String description, String date, String time){
    return new Card(
      elevation: 10.0,
      margin: EdgeInsets.all(15.0),
      child: new Container(
        padding: new EdgeInsets.all(14.0),

        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(
                  date,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,


                ),
                new Text(
                  time,
                  style: Theme.of(context).textTheme.subtitle,
                  textAlign: TextAlign.center,


                ),
                GestureDetector(
                  child: Icon(Icons.file_download, color: Colors.black, size: 20,),
                  onTap: () async{
                    setState(() {
                      showSpinner1 = true;
                    });


                    var response = await Dio().get(image, options: Options(responseType: ResponseType.bytes));
                    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
                    print(result);

               //     var response = await http.get(image);
                 //    await ImagePickerSaver.saveFile(fileData: response.bodyBytes);
                    setState(() {
                      showSpinner1 = false;
                    });
                  },
                )

              ],
            ),
            SizedBox(height: 10.0,),

            new Image.network(image, fit: BoxFit.cover),
            SizedBox(height: 10.0,),
                new Text(
                  description,
                  style: Theme.of(context).textTheme.subhead,
                  textAlign: TextAlign.center,
                  

                ),

          ],
        ),
      ),
    );
  }
}