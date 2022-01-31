import 'package:flutter/material.dart';
import 'package:un_watchd/services/auth.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String error = '';

  String username = '';
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Text("unWatchd",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontFamily: 'Chela One',
                        fontSize: 30)),
                SizedBox(height: 20.0),
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
                  maxLength: 50,
                  decoration: new InputDecoration(
                      counterText: '',
                      labelText: "Email",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      )),
                  validator: (val) => val.isEmpty ? 'Enter an email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
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
                  validator: (val) =>
                      val.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                SizedBox(height: 20.0),
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
                        if (_formKey.currentState.validate()) {
                          _auth
                              .signUp(username, password, email)
                              .then((result) {
                            if (result) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            } else {
                              setState(() {
                                error =
                                    'Could not create account, please try again';
                              });
                            }
                          });
                        }
                      }),
                ),
                SizedBox(height: 20.0),
                ButtonTheme(
                  height: 44,
                  child: RaisedButton(
                      color: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
