// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:un_watchd/models/extraInfo.dart';
import 'package:un_watchd/main.dart';
import 'package:un_watchd/screens/authenticate/login.dart';
//import 'package:un_watchd/screens/home/movieView.dart';
import 'package:un_watchd/services/auth.dart';

class MockAuth implements AuthService {
  bool didTrySignIn = false;
  @override
  Future<bool> signUp(String username, String password, String email) async {
    //implement shit
  }
  @override
  Future<bool> login(String username, String password) async {
    didTrySignIn = true;
  }

  @override
  Future<void> logout() async {
    //implement shit
  }
}

void main() {
  Widget makeTestableWidget({Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  testWidgets('Login with empty fields', (WidgetTester tester) async {
    //MockAuth auth = MockAuth();
    //AuthService auth = AuthService();
    //LoginPage page = LoginPage();
    await tester.pumpWidget(MyApp());
    //var button = find.text('Login');
    //await tester.pump();
    //expect(button, findsOneWidget);
    //expect(auth.didTrySignIn, true);
  });
}
