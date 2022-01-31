import 'package:flutter/material.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/screens/home/profile.dart';
import 'package:un_watchd/screens/home/single_review.dart';

class NotificationObject {
  String username;
  String act;

  NotificationObject(Map<String, dynamic> data) {
    username = data['username'];
    act = data['act'];
  }
}

List<Card> _notificationFromData(var data, BuildContext context) {
  List<Card> allNotific = [];
  List<dynamic> notifs = data;
  for (int i = 0; i < notifs.length; i++) {
    ///// LIKES
    if (notifs[i]['type'] == "like") {
      allNotific.add(
        Card(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          elevation: 4,
          child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('images/popped.jpg'),
                                fit: BoxFit.cover),
                            //borderRadius: BorderRadius.all(Radius.circular(65.0)),
                          )),
                      Row(children: <Widget>[
                        notifs[i]['username'] != null
                            ? Text(" " + notifs[i]['username'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18))
                            : Text("N/A"),
                        Text(" popped you review",
                            style: TextStyle(fontSize: 18)),
                      ]),
                    ],
                  ),
                  Text(
                    notifs[i]['timestamp'] == null ||
                            notifs[i]['timestamp'] == "null" ||
                            notifs[i]['timestamp'] == ""
                        ? "00:00"
                        : notifs[i]['timestamp'],
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              onTap: () {
                int reviewID;
                try {
                  reviewID = notifs[i]['review_id'];
                } catch (e) {
                  print("Could not resolve review_id in onTAP for comment");
                  return;
                }
                var overlay = null;
                overlay = OverlayEntry(
                    builder: (context) => Positioned(
                          left: 0,
                          top: 25,
                          right: 0,
                          child: Material(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                new SingleReview(reviewID, overlay),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    iconSize: 30,
                                    onPressed: () {
                                      overlay.remove();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ), //Text("test"),
                        ));
                Overlay.of(context).insert(overlay);
              }),
        ),
      );
    }
    ///// COMMENTS
    else if (notifs[i]['type'] == "comment") {
      String comment;
      try {
        comment = notifs[i]['comment'];
      } catch (e) {
        comment = "N/A";
      }
      if (comment.length > 20) comment = comment.substring(0, 30) + "...";
      allNotific.add(
        Card(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          elevation: 4,
          child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('images/commentICON.png'),
                                fit: BoxFit.cover),
                          )),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 1,
                        child: Wrap(
                          children: <Widget>[
                            notifs[i]['username'] != null
                                ? Text(" " + notifs[i]['username'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18))
                                : Text("N/A"),
                            Text(" commented:", style: TextStyle(fontSize: 18)),
                            Text(" $comment ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ),
                      notifs[i]['poster'] == null
                          ? SizedBox(
                              width: 45,
                              height: 60,
                              child: Center(
                                  child: Text("No poster",
                                      style: TextStyle(
                                        color: Colors.black,
                                      ))),
                            )
                          : Image.network(notifs[i]['poster'],
                              width: 45, height: 60, fit: BoxFit.fitHeight),
                    ],
                  ),
                  Text(
                    notifs[i]['timestamp'] == null ||
                            notifs[i]['timestamp'] == "null" ||
                            notifs[i]['timestamp'] == ""
                        ? "00:00"
                        : notifs[i]['timestamp'],
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              onTap: () {
                int reviewID;
                try {
                  reviewID = notifs[i]['review_id'];
                } catch (e) {
                  print("Could not resolve review_id in onTAP for comment");
                  return;
                }
                var overlay = null;
                overlay = OverlayEntry(
                    builder: (context) => Positioned(
                          left: 0,
                          top: 25,
                          right: 0,
                          child: Material(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                new SingleReview(reviewID, overlay),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    iconSize: 30,
                                    onPressed: () {
                                      overlay.remove();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ), //Text("test"),
                        ));
                Overlay.of(context).insert(overlay);
              }),
        ),
      );
    }
    //// FOLLOWS
    else if (notifs[i]['type'] == "follower") {
      allNotific.add(
        Card(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          elevation: 4,
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.person_add, size: 50),
                    Row(children: <Widget>[
                      notifs[i]['username'] != null
                          ? Text(" " + notifs[i]['username'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18))
                          : Text("N/A"),
                      Text(" started following you",
                          style: TextStyle(fontSize: 18)),
                    ]),
                  ],
                ),
                Text(
                  notifs[i]['timestamp'] == null ||
                          notifs[i]['timestamp'] == "null" ||
                          notifs[i]['timestamp'] == ""
                      ? "00:00"
                      : notifs[i]['timestamp'],
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            onTap: () {
              if (notifs[i]['username'] != null &&
                  notifs[i]['user_id'] != null) {
                print(
                    "onTap CALLED::::::::::::::::::::::::::::::::::::::::::ID: " +
                        notifs[i]['user_id'].toString());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => new Profile(
                          notifs[i]['username'], notifs[i]['user_id'], 0, 0, 0),
                      fullscreenDialog: true,
                    ));
              } else {
                final snackBar = SnackBar(
                  backgroundColor: Colors.white,
                  content: Text("Failed, user not found"),
                );

                Scaffold.of(context).showSnackBar(snackBar);
              }
            },
          ),
        ),
      );
    }
  }
  return allNotific;
}

void func() {}

class Notifications extends StatefulWidget {
  @override
  NotificationState createState() => NotificationState();
}

class NotificationState extends State<Notifications> {
  ServerCommunication _serverCommunication = ServerCommunication();

  Future<List<dynamic>> notifications;
  //static var postObj = postObject(parsedJson);
  @override
  void initState() {
    print('init');
    super.initState();
    notifications = loadNotifications();
    print("printing in INIT: " + notifications.toString());
    print('init done');
  }

  Future<List<dynamic>> loadNotifications() async {
    print("Load Noifications");
    var result;
    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await _serverCommunication.getNotifications().then((onValue) {
        result = onValue;
      });
    });

    return result;
  }

  Future _refresh() async {
    setState(() {
      notifications = loadNotifications();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print("Körs denna?");
    return Scaffold(
      body: Container(
          color: Colors.white,
          child: FutureBuilder<List<dynamic>>(
              future: notifications,
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                    onRefresh: _refresh,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor: Colors.redAccent,
                          pinned: true,
                          expandedHeight: 50.0,
                          title: Text("Activity",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white)),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              //=======================================================================================================
                              if (index == 0) {
                                return Container(
                                  padding: const EdgeInsets.all(5),
                                  color: Colors.white,
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        //children:_notificationFromData(testData),
                                        children: _notificationFromData(
                                            snapshot.data, context),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              //=======================================================================================================
                              else if (index == 2) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: new Row(
                                    children: <Widget>[
                                      // Top row with name and logout button
                                      Text("Earlier",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20)),
                                    ],
                                  ),
                                );
                              }

                              //========================================================================================================
                              else if (index == 3) {
                                return Center(
                                  heightFactor: 1,
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 40),
                                    color: Colors.white,
                                    height: 300,
                                    child: Text("No more activity",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: Colors.grey)),
                                  ),
                                );
                              } else
                                return null;
                            },
                          ),
                        ),
                      ],
                    ));
              })),
    );
  }
}
