import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:un_watchd/main.dart' as main;
import 'package:un_watchd/services/auth.dart' as auth;
import 'package:un_watchd/services/serverCom.dart';

class Comments extends StatefulWidget {
  int review_id;
  List<dynamic> _list;
  Comments(int rev, List<dynamic> list) {
    review_id = rev;
    _list = list;
  }

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  bool listHasNotBeenBuild = true;
  List<dynamic> _comments = [];
  ServerCommunication _serverCommunication = ServerCommunication();

  final textController = TextEditingController();

  void _addComment(String val) async {
    int id = widget.review_id;
    bool cont = true;
    String error;
    
    main.socket.write('COMMENT {"comment":"$val", "review_id":$id}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      print(dataString);
      var parsedData = JsonDecoder().convert(dataString);
      error = parsedData['error'];
      print(error);
      cont = false;
    });

    print('Streamen skapa');

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 1000), () {
        print("waiting");
      });
    }
    var time = new DateTime.now();
    String str = DateFormat('yyyy-MM-dd kk:mm:ss').format(time);
    String username = auth.usernameLOGGEDIN;
    setState(() {
      _comments.insert(0,
          {"comment": "$val", "username": "$username", "time_stamp": "$str"});
    });
    stream.cancel();
  }

  Widget _buildCommentList() {
    return ListView.builder(
        reverse: true,
        itemBuilder: (context, index) {
          if (index < _comments.length) {
            var temp = _comments[index];
            return _buildCommentItem(
                temp['comment'], temp['username'], temp['time_stamp']);
          }
        });
  }

  Widget _buildCommentItem(String comment, String user, String timestamp) {
    return Card(
      child: ListTile(
        title: Text(comment),
        subtitle: Text(user + " " + timestamp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (listHasNotBeenBuild) {
      _serverCommunication.listening();
      for (var i = 0; i < widget._list.length; i++) {
        setState(() {
          var temp = widget._list[i];
          _comments.insert(0, temp);
        });
      }
      listHasNotBeenBuild = false;
    }

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      var parsedData = JsonDecoder().convert(dataString);
      // Kolla så att widget.review_id stämmer överens med vilket inlägg som kommentaren hör till
      print(parsedData);
      if (parsedData['comment'] != null &&
          _comments[0]['comment'] != parsedData['comment'] &&
          widget.review_id == parsedData['review_id']) {
        print(parsedData);
        setState(() {
          _comments.insert(0, parsedData);
        });
      }
    });

    return Scaffold(
      appBar: new AppBar(
          backgroundColor: Colors.black87,
          elevation: 0.0,
          title: Text('Comments'),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                stream.cancel();
                _serverCommunication.stop_listening();
                Navigator.pop(context);
                //Navigator.of(context).pushReplacementNamed('/home');
              })),
      body: Column(
        children: <Widget>[
          Expanded(child: _buildCommentList()),
          Container(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              maxLength: 255,
              controller: textController,
              onSubmitted: (str) {
                textController.clear();
                _addComment(str); //_addComment(str);
              },
              decoration: new InputDecoration(
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
