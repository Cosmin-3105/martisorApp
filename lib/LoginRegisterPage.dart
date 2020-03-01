import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Authentification.dart';
import 'RoundedButton.dart';
import 'constants.dart';
import 'DialogBox.dart';

class LoginRegisterPage extends StatefulWidget {
  LoginRegisterPage({
    this.auth,
    this.onSignedIn,
  });
  final AuthImplementaion auth;
  final VoidCallback onSignedIn;
  State<StatefulWidget> createState() {
    return _LoginRegisterState();
  }
}

enum FormType { login, register }

class _LoginRegisterState extends State<LoginRegisterPage>   with SingleTickerProviderStateMixin {
  DialogBox dialogBox = new DialogBox();
  bool showSpinner = false;
  final formKey = new GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = "";
  String _password = "";
  AnimationController controller;
  Animation animation;


  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);

    animation =
        ColorTween(begin: Colors.red[300], end: Colors.white).animate(controller);

    controller.forward();

    controller.addListener(() {
      setState(() {});
    });

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
  }

  //metode
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    setState(() {
      showSpinner = true;
    });
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.SignIn(_email, _password);
          //dialogBox.information(context, "Felicitari ", "te-ai logat cu succes");
          print("login userId = " + userId);
          setState(() {
            showSpinner = false;
          });
        } else {
          String userId = await widget.auth.SignUp(_email, _password);
          //dialogBox.information(context, "Felicitari ", "Contul tau a fost creat cu succes!");
          print("Register userId = " + userId);
          setState(() {
            showSpinner = false;
          });
        }

        widget.onSignedIn();
      } catch (e) {
        dialogBox.information(context, "Eroare!!! ",
            "Trebuie sa introduci datele unui cont valid.");
        setState(() {
          showSpinner = false;
        });

        /// print("Error = " + e.toString());
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();

    setState(() {
      _formType = FormType.login;
    });
  }

  //design
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: animation.value,
      // appBar: new AppBar(
      // title: new Text("Social App"),
      //),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: new Container(
          margin: EdgeInsets.all(15.0),
          child: new Form(
            key: formKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: createInputs() + createButtons(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> createInputs() {
    return [
      SizedBox(height: 70.0),
      logo(),
      SizedBox(height: 20.0),
      new TextFormField(
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.center,
        decoration: kTextFieldDecoration,
        validator: (value) {
          return value.isEmpty ? 'Trebuie sa introduci emailul.' : null;
        },
        onSaved: (value) {
          return _email = value;
        },
      ),
      SizedBox(height: 10.0),
      new TextFormField(
        textAlign: TextAlign.center,
        decoration: kTextFieldDecoration.copyWith(hintText: 'Scrie parola ta'),
        obscureText: true,
        validator: (value) {
          return value.isEmpty ? 'Trebuie sa introduci parola.' : null;
        },
        onSaved: (value) {
          return _password = value;
        },
      ),
      SizedBox(height: 20.0),
    ];
  }

  Widget logo() {
    return Flexible(
        child: new CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 110.0,
            child: Column(
              children: <Widget>[
                Flexible(
                    child: Hero(
                        tag: 'logo', child: Image.asset('images/logo.png'))),
              ],
            )));
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return [
        RoundedButton(
          color: Colors.red[300],
          text: 'Conectează-te',
          onPressed: validateAndSubmit,
        ),
        Hero(
          tag: 'reg',
          child: RoundedButton(
            color: Colors.red[500],
            text: 'Înscrie-te',
            onPressed: moveToRegister,
          ),
        ),
      ];
    } else {
      return [
        Hero(
          tag: 'reg',
          child: RoundedButton(
            text: 'Înscrie-te',
            color: Colors.red[400],
            onPressed: validateAndSubmit,
          ),
        ),
        new FlatButton(
          child: new Text("Ai deja un cont? Logare?",
              style: new TextStyle(fontSize: 14.0)),
          textColor: Colors.redAccent,
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
