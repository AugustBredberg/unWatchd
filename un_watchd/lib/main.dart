import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:retry/retry.dart';

import 'dart:io';
import 'dart:async';

import 'package:un_watchd/screens/authenticate/login.dart';
import 'package:un_watchd/screens/authenticate/reconnect.dart';
import 'package:un_watchd/screens/authenticate/sign_up.dart';
import 'package:un_watchd/screens/home/home.dart';
import 'package:un_watchd/screens/home/post.dart';
import 'package:un_watchd/services/auth.dart' as authVariables;
import 'package:un_watchd/services/auth.dart';

Widget _defaultHome;
Socket socket;
Stream<Uint8List> socketStream;
final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void onDisconnected(bool reconnect) async {
  print('Disconnected');
  if (socket != null) {
    print("Socket stängs");
    socket.close();
  }
  socket = null;
  final r = RetryOptions(maxAttempts: 3);
  try {
    final success = await r.retry(
      () async {
        print("retry");
        await connect();
        return true;
      },
      retryIf: (e) => e is SocketException || e is TimeoutException,
    );
    if (success) {
      final AuthService _auth = AuthService();
      print("true");
      _auth
          .login(authVariables.usernameLOGGEDIN, authVariables.passwordLOGGEDIN)
          .then((result) async {
        if (result) {
          if (reconnect) {
            navigatorKey.currentState.pushReplacementNamed('/home');
          } else {
            navigatorKey.currentState.reassemble();
          }
        } else {
          navigatorKey.currentState.pushReplacementNamed('/login');
        }
      });
    }
  } catch (e) {
    print("false");
    navigatorKey.currentState.pushReplacementNamed('/reconnect');
  }
}

void _onDisconnected() {
  onDisconnected(false);
}

Future<bool> connect() async {
  bool success = false;
  //socket = await Socket.connect('192.168.1.5', 8888);
  socket = await Socket.connect(
      'ec2-13-49-72-142.eu-north-1.compute.amazonaws.com', 8888);
  socketStream = socket.asBroadcastStream();
  socketStream.listen(
    (_) {
      print("Just listening, not doing anything else");
    },
    onDone: _onDisconnected,
  );
  print('connected');
  success = true;
  return success;
}

void main() async {
  // Connection to the server
  await connect();
  // Sets the startwidget
  _defaultHome = new LoginPage();

  // Runs app and prevents user from switching oritentation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'App',
      home: _defaultHome,
      routes: <String, WidgetBuilder>{
        // Set named routes for using the Navigator.
        '/home': (BuildContext context) => new HomePage(),
        '/login': (BuildContext context) => new LoginPage(),
        '/signUp': (BuildContext context) => new SignUp(),
        '/post': (BuildContext context) => new Post("", ""),
        '/reconnect': (BuildContext context) => new Reconnect()
      },
      // Enables switching between widgets without accesess to context
      navigatorKey: navigatorKey,
    );
  }
}
