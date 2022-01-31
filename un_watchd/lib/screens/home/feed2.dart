import 'package:flutter/material.dart';
import 'package:un_watchd/screens/home/comments.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/services/auth.dart' as auth;
import 'dart:async';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:un_watchd/screens/home/profile.dart';
import 'package:un_watchd/screens/home/movieView.dart';

class Feed2 extends StatefulWidget {
  @override
  _Feed2State createState() => _Feed2State();
}

class _Feed2State extends State<Feed2> {
  Future<List<dynamic>> _activities;
  ServerCommunication _serverCommunication = ServerCommunication();
  int counter = 1;
  bool listHasNotBeenBuilt = true;
  var _liked = [];
  @override
  void initState() {
    super.initState();
    _activities = _getTimeline(counter, true);
  }

  void _printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<List<dynamic>> _getTimeline(int count, bool refresh) async {
    return await _serverCommunication.getTimeline(count, refresh);
  }

  Future _refreshActivities() async {
    setState(() {
      counter++;
      _activities = _getTimeline(counter, false);
    });
    return null;
  }

  Future _reloadActivities() async {
    setState(() {
      _liked.clear();
      listHasNotBeenBuilt = true;
      counter = 1;
      _activities = _getTimeline(counter, true);
    });
    return null;
  }

  List<Icon> _starsForRatings(rating) {
    List<Icon> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < rating) {
        if (rating == i + 0.5)
          stars.add(Icon(Icons.star_half, color: Colors.yellow));
        else
          stars.add(Icon(Icons.star, color: Colors.yellow, size: 28));

        //stars.add(Icon(Icons.star, color: Colors.yellow));
      } else
        stars.add(Icon(Icons.star, size: 28));
    }
    return stars;
  }

  void _pressed(int review_id) {
    setState(() {
      if (_liked.contains(review_id)) {
        _serverCommunication.unlike(review_id);
        _liked.remove(review_id);
      } else {
        _serverCommunication.like(review_id);
        _liked.add(review_id);
      }
    });
  }

  Image imageChecker(String url) {
    print("URL:");
    print(url);
    if (url == 'N/A' || url == null || url == 'null') {
      print("1");
      return Image.asset('images/logoTRANS.png', height: 80);
    } else {
      print("2");
      return Image.network(url, height: 60);
    }
  }

  void _buildLiked(dynamic json) {
    if (listHasNotBeenBuilt) {
      print("Kommmer hit");
      _printWrapped(json.toString());
      for (var i = 0; i < json.length; i++) {
        List temp = json[i]['likers'];
        print("lista av likers");
        print(temp);
        for (var j = 0; j < temp.length; j++) {
          if (temp[j]['username'] == auth.usernameLOGGEDIN) {
            print("likead");
            _liked.add(json[i]['review_id']);
            temp.removeAt(j);
          }
        }
      }
      listHasNotBeenBuilt = false;
    }
  }

  /////////////
  /// BUILD
  /////////////
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
        future: _activities,
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          print("BAABBABABBABA");
          return StickyHeader(
              overlapHeaders: true,
              header: Container(
                padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
                height: 80.0,
                color: Colors.redAccent,
                //padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Image.asset('images/logoTRANS.png', width: 50, height: 50),
                    Text("unWatchd",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Chela One',
                            fontSize: 30)),
                  ],
                ),
              ),
              content: Container(
                padding: const EdgeInsets.only(top: 45.0, left: 0, right: 0),
                child: Center(
                  child: RefreshIndicator(
                    onRefresh: _reloadActivities,
                    child: ListView.builder(
                      itemCount: snapshot.data.length % 10 != 0
                          ? snapshot.data.length
                          : snapshot.data.length + 1,
                      itemBuilder: (context, index) {
                        var _list = snapshot.data;
                        if (_list.length != 0) {
                          _buildLiked(snapshot.data);
                        }
                        if (index == snapshot.data.length) {
                          return Container(
                            color: Colors.redAccent,
                            child: FlatButton(
                              child: Text("Load More"),
                              onPressed: () {
                                _refreshActivities();
                              },
                            ),
                          );
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            color: Colors.grey[100],
                            child: Card(
                              margin: EdgeInsets.only(top: 10, bottom: 10),
                              elevation: 4,
                              //shape: ShapeBorder.
                              child: Container(
                                //padding: const EdgeInsets.all(4.0),
                                child: new Column(
                                  children: <Widget>[
                                    // User Details
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4, top: 4, bottom: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          // Här ska koden vara för bilden
                                          _list[index]['profile_img'] != null &&
                                                  _list[index]['profile_img'] !=
                                                      "null" &&
                                                  _list[index]['profile_img'] !=
                                                      ""
                                              ? Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            _list[index][
                                                                'profile_img']),
                                                        fit: BoxFit.cover),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                65.0)),
                                                  ))
                                              : Container(
                                                  width: 50.0,
                                                  height: 50.0,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            'images/logoTRANS.png'),
                                                        fit: BoxFit.cover),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                65.0)),
                                                  )),
                                          //AssetImage('images/logoTRANS.png'),

                                          GestureDetector(
                                              child: Text(
                                                  _list[index]['username'] ==
                                                          null
                                                      ? ""
                                                      : "  " +
                                                          _list[index]
                                                              ['username'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18)),
                                              onTap: () async {
                                                print(
                                                    "onTap called.(user) + add id");
                                                print(_list[index]['username']);
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          new Profile(
                                                              _list[index]
                                                                  ['username'],
                                                              _list[index]
                                                                  ['user_id'],
                                                              0,
                                                              0,
                                                              0),
                                                      fullscreenDialog: true,
                                                    ));
                                                Navigator.pushReplacementNamed(
                                                    context, '/home');
                                                //setState(() {});
                                              }),

                                          Spacer(),
                                        ],
                                      ),
                                    ),
                                    //Divider(),
                                    GestureDetector(
                                      child: Container(
                                        //height: 200,
                                        //width:200,
                                        color: Colors.white,
                                        child: _list[index]['review_img'] !=
                                                    null &&
                                                _list[index]['review_img'] !=
                                                    "null" &&
                                                _list[index]['review_img'] != ""
                                            ? Image.network(
                                                _list[index]['review_img'],
                                                fit: BoxFit.fitWidth,
                                              )
                                            : null, //Image.network('https://cdn.discordapp.com/attachments/300997774990639104/696797826243624990/logga2.png'),
                                      ),
                                      onDoubleTap: () {
                                        print(_list[index]['review_id']);
                                        _pressed(_list[index]['review_id']);
                                      },
                                    ),

                                    // FILM OCH RATING
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          /// POSTER FOR MOVIE IF EXISTING

                                          GestureDetector(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: imageChecker(
                                                  _list[index]['poster'],
                                                ), //Image.network(filteredMovies[index].url, height: 80,),
                                              ),
                                            ),
                                            onTap: () {
                                              _serverCommunication
                                                  .sendExtra(
                                                      _list[index]['IMDB_id'])
                                                  .then((onValue) {
                                                print(onValue.director);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          new MovieView(
                                                              _list[index]
                                                                  ['title'],
                                                              "N/A",
                                                              _list[index]
                                                                  ['IMDB_id'],
                                                              _list[index]
                                                                  ['poster'],
                                                              onValue)),
                                                );
                                              });
                                            },
                                          ),

                                          Flexible(
                                            fit: FlexFit.tight,
                                            flex: 20,
                                            child: Text(
                                                (_list[index]['title'] == null
                                                    ? ""
                                                    : _list[index]['title']),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18)),
                                          ),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: _starsForRatings(
                                                _list[index]['rating'] == null
                                                    ? 3.0
                                                    : double.parse(_list[index]
                                                        ['rating'])),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Caption
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      //padding: const EdgeInsets.only(left: 4, right: 4),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          direction: Axis.horizontal,
                                          children: <Widget>[
                                            RichText(
                                              text: TextSpan(
                                                  style: DefaultTextStyle.of(
                                                          context)
                                                      .style,
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: _list[index][
                                                                    'username'] ==
                                                                null
                                                            ? ""
                                                            : _list[index]
                                                                ['username'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15)),
                                                    TextSpan(
                                                        text: " " +
                                                            (_list[index][
                                                                        'caption'] ==
                                                                    null
                                                                ? ""
                                                                : _list[index][
                                                                    'caption']),
                                                        style: TextStyle(
                                                            fontSize: 15)),
                                                  ]),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ikoner för poppa, kommentera och dela
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        // pop knapp, comment knapp osv under bilden
                                        GestureDetector(
                                          child: Tab(
                                              icon: _liked.contains(
                                                      _list[index]['review_id'])
                                                  ? Image.asset(
                                                      "images/popped.jpg",
                                                      width: 35,
                                                      height: 35,
                                                    )
                                                  : Image.asset(
                                                      "images/unpopped.jpg",
                                                      width: 30,
                                                      height: 30,
                                                    )),
                                          onTap: () {
                                            print(_list[index]['review_id']);
                                            _pressed(_list[index]['review_id']);
                                          },
                                        ),
                                        Text(
                                            _list[index]['likers'] == null
                                                ? "0"
                                                : _liked.contains(_list[index]
                                                        ['review_id'])
                                                    ? (_list[index]['likers']
                                                                .length +
                                                            1)
                                                        .toString()
                                                    : _list[index]['likers']
                                                        .length
                                                        .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),

                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: GestureDetector(
                                              child: Tab(
                                                  icon: Image.asset(
                                                "images/commentICON.png",
                                                width: 40,
                                                height: 40,
                                              )),
                                              onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute<dynamic>(
                                                      builder: (context) =>
                                                          new Comments(
                                                              _list[index]
                                                                  ['review_id'],
                                                              _list[index][
                                                                  'comments'])))),
                                        ),
                                        Text(
                                            _list[index]['comments'] == null
                                                ? "0"
                                                : _list[index]['comments']
                                                    .length
                                                    .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18)),
                                        Spacer(),

                                        Spacer(),
                                        Spacer(),
                                      ],
                                    ),

                                    // Kommentarer

                                    // time stamp
                                    Text(
                                      _list[index]['time_stamp'] == null
                                          ? "00:00"
                                          : _list[index]['time_stamp'],
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ));
        });
  }
}
