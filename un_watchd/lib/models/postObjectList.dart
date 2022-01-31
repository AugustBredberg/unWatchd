import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:un_watchd/main.dart' as main;
import 'package:un_watchd/models/postObject.dart';

class PostObjectList extends ChangeNotifier {
  List<PostObject> _list = [];
  int counter = 1;
  bool isRefreshing = false;

  List<PostObject> get postObjectList => _list;

  set postObjectList(List<PostObject> postList) {
    _list = postList;
    notifyListeners();
  }

  PostObject getFirstPostObject() {
    var result;
    if (_list.length <= 0) {
      print("nulllll");
      result = null;
    } else {
      print("not nullll");
      result = _list[0];
      _list.removeAt(0);
    }

    return result;
  }

  int getLength() {
    return _list.length;
  }

  refreshList() async {
    if (!isRefreshing) {
      isRefreshing = true;
      var templist;
      bool cont = true;
      print("Skriver till servern");
      main.socket.write('HOME FEED {"index":$counter}');

      StreamSubscription<Uint8List> stream =
          main.socketStream.listen((Uint8List event) {
        String dataString = String.fromCharCodes(event);
        print(dataString);
        var parsedData = JsonDecoder().convert(dataString);
        templist = parsedData['feed'];
        cont = false;
      });

      while (cont) {
        await Future.delayed(const Duration(milliseconds: 500), () {
          print('Waiting');
        });
      }
      stream.cancel();

      for (var i = 0; i < templist.length; i++) {
        var obj = templist[i];
        print(obj['review_img']);
        _list.add(new PostObject(obj));
      }
      isRefreshing = false;
      print("done");
    }
  }
}
