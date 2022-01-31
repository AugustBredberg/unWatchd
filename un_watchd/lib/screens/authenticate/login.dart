import 'package:flutter/material.dart';
import 'package:un_watchd/services/auth.dart';
import 'package:un_watchd/main.dart' as main;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = main.socket == null ? 'No connection' : '';
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new SingleChildScrollView(
          child: new Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 30.0),
                  Image.asset('images/logoTRANS.png', width: 1400, height: 140),
                  SizedBox(height: 20.0),
                  Text("unWatchd",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontFamily: 'Chela One',
                          fontSize: 30)),
                  SizedBox(height: 10.0),
                  Text(
                    error,
                    style: TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    maxLength: 30,
                    decoration: new InputDecoration(
                        counterText: '',
                        labelText: "Username",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(),
                        )),
                    validator: (val) => val.isEmpty ? 'Enter a username' : null,
                    onChanged: (val) {
                      setState(() => username = val);
                    },
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    maxLength: 30,
                    obscureText: true,
                    decoration: new InputDecoration(
                        counterText: '',
                        labelText: "Password",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(),
                        )),
                    validator: (val) => val.length < 2
                        ? 'Enter a password 6+ chars long'
                        : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  SizedBox(height: 10.0),
                  ButtonTheme(
                    height: 44,
                    child: RaisedButton(
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _auth.login(username, password).then((result) {
                              if (result) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              } else {
                                setState(() {
                                  error =
                                      'Could not sign in with those credentials';
                                });
                              }
                            });
                          }
                        }),
                  ),
                  SizedBox(height: 16.0),
                  ButtonTheme(
                    height: 44,
                    child: RaisedButton(
                        color: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/signUp');
                        }),
                  ),
                  SizedBox(height: 12.0),
                  Text('2020 \u00a9 dsp-bossy'),
                ],
              ),
            ),
          ),
        ),
      );
}
