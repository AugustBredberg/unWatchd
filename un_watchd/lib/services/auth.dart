import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:un_watchd/main.dart' as main;
import 'package:crypto/crypto.dart';

String usernameLOGGEDIN = "";
String passwordLOGGEDIN = "";

class AuthService {
  // Sign in
  Future<bool> login(String username, String password) async {
    // Simulate a future for response after 2 second.
    //String result;
    bool success = false;
    bool cont = true;
    String str = "";
    var parsedData;
    var passwordTemp = utf8.encode(password);
    var passwordEncrypted = sha512.convert(passwordTemp);

    print(password);
    print(passwordTemp);
    print(
        "Digest as hex string: $passwordEncrypted"); //Change password to passwordEncrypted in socket write

    main.socket
        .write('LOGIN {"username": "$username", "password": "$password"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;

      try {
        var parsedData = JsonDecoder().convert(str);
        success = parsedData['success'];
      } catch (e) {
        print("Continue listening");
      }

      parsedData = JsonDecoder().convert(dataString);
      cont = false;
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print('Logging in');
      });
    }

    if (success == true) {
      print("success");
      usernameLOGGEDIN = username;
      passwordLOGGEDIN = password;
    }

    stream.cancel();
    return success;
  }

  // Register
  Future<bool> signUp(String username, String password, String email) async {
    var passwordTemp = utf8.encode(password);
    var passwordEncrypted = sha512.convert(passwordTemp);
    bool cont = true;
    bool success;
    String str = "";

    print(password);
    print(passwordTemp);
    print(
        "Digest as hex string: $passwordEncrypted"); //Change password to passwordEncrypted in socket write

    main.socket.write('CREATE PROFILE {' +
        '"username": "$username",' +
        '"email": "$email",' +
        '"password": "$password",' +
        '"img":""}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        success = parsedData['success'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print('Logout');
      });
    }

    stream.cancel();

    return success;
  }

  // Log out
  Future<void> logout() async {
    bool cont = true;
    main.socket.write('LOGOUT');
    usernameLOGGEDIN = "";
    passwordLOGGEDIN = "";

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);

      print(dataString);
      cont = false;
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print('Logout');
      });
    }

    stream.cancel();
    // Simulate a future for response after 1 second.
    return null;
  }
}
