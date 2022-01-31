import 'package:flutter/material.dart';
import 'package:un_watchd/main.dart' as main;

class Reconnect extends StatefulWidget {
  @override
  _ReconnectState createState() => _ReconnectState();
}

class _ReconnectState extends State<Reconnect> {
  String error = 'No connection';
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text('Reconnect'),
          backgroundColor: Colors.black87,
        ),
        body: new Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                    color: Colors.redAccent,
                    child: Text(
                      'Reconnect',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() => error = 'Trying to reconnect');
                      main.onDisconnected(true);
                    }),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      );
}
