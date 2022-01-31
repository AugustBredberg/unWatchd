import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:un_watchd/screens/home/comments.dart';
import 'package:un_watchd/services/auth.dart';
import 'package:un_watchd/services/auth.dart' as auth;
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/models/profileInfo.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sticky_headers/sticky_headers.dart';

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

// function for generating recent activity
List<Column> _recentActivity(List<dynamic> data) {
  List<String> imgURLS = [];
  List<String> ratings = [];
  List<String> titles = [];
  for (int i = 0; i < data.length; i++) {
    try {
      imgURLS.add(data[i]['poster']);
    } catch (e) {
      imgURLS.add(null);
    }

    try {
      ratings.add(data[i]['rating']);
    } catch (e) {
      ratings.add("0");
    }

    try {
      titles.add(data[i]['title']);
    } catch (e) {
      titles.add("Nothing");
    }
  }
  print("LIST OF URLS:::::::::::::::::" + imgURLS.toString());
  print("LIST OF RATINGS:::::::::::::::::" + ratings.toString());
  print("LIST OF TITLES:::::::::::::::::" + titles.toString());

  List<Column> moviesRated = [];
  //List<bool> rated = [true, true, true, true];
  for (int i = 0; i < 4; i++) {
    if (i < ratings.length) {
      String url = imgURLS[i];
      moviesRated.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          url == null || url == "" || url == "null" || url == "N/A"
              ? SizedBox(
                  width: 80,
                  height: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(),
                    ),
                    child: Center(
                        child: Text('N/A',
                            style:
                                TextStyle(color: Colors.white, fontSize: 20))),
                  ),
                )
              : Image.network(
                  //imgURLS[i] == null || imgURLS[i] == "" ?
                  //"images/shrek2.jpg" :
                  "$url",
                  width: 80,
                  height: 140,
                  fit: BoxFit.fitHeight),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: _starsForRatings(double.parse(ratings[i])),
            /*
              Icon(Icons.star, color: Colors.yellow, size: 16),
              Icon(Icons.star, color: Colors.yellow, size: 16),
              Icon(Icons.star, color: Colors.yellow, size: 16),
              Icon(Icons.star, color: Colors.yellow, size: 16),
              */
          ),
        ],
      ));
      //stars.add(Icon(Icons.star, color: Colors.yellow));
    } else {
      moviesRated.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 80,
            height: 140,
            child: Center(
                child: Text("N/A",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24))),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: <Widget>[
              Icon(Icons.star, color: Colors.grey, size: 16),
              Icon(Icons.star, color: Colors.grey, size: 16),
              Icon(Icons.star, color: Colors.grey, size: 16),
              Icon(Icons.star, color: Colors.grey, size: 16),
              Icon(Icons.star, color: Colors.grey, size: 16),
            ],
          ),
        ],
      ));
    }
    //stars.add(Icon(Icons.star));
  }
  return moviesRated;
}

List<Icon> _starsForRatings(rating) {
  List<Icon> stars = [];

  for (int i = 0; i < 5; i++) {
    if (i < rating) {
      if (rating == i + 0.5)
        stars.add(Icon(Icons.star_half, color: Colors.yellow, size: 16));
      else
        stars.add(Icon(Icons.star, color: Colors.yellow, size: 16));
    } else
      stars.add(Icon(Icons.star, size: 16));
  }
  return stars;
}

class Profile extends StatefulWidget {
  String username;
  int userID;

  Profile(usern, usrID, revs, followersMy, followingMy) {
    username = usern;
    userID = usrID;
  }

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  ServerCommunication _serverCommunication = ServerCommunication();
  AuthService _auth = AuthService();

  Future<ProfileInfo> profileInfo;
  Future<List<dynamic>> mostRecent;

  bool pressedFollow;
  bool listHasNotBeenBuilt = true;
  String textHolder;
  String profilePictureURL;
  NetworkImage profilePicture;
  Future<List<dynamic>> _activities;
  int counter = 1;
  var _liked = [];

  @override
  void initState() {
    print('init');
    super.initState();
    profileInfo = getProfileInfo();
    //mostRecent = mostRecent = getRecentActivity();//null; //getRecentActivity();
    _activities = null;
    print('init done');
  }

  ////// FUNCTIONS FOR PICKING PROFILE PICTURE
  getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    File croppedFile;
    //File result;

    print(image.readAsBytesSync());
    if (image != null) {
      croppedFile = await ImageCropper.cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
    }
    await _serverCommunication.uploadProfilePic(croppedFile).then((_) {});
  }

  getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    File croppedFile;
    //File result;
    print(image.readAsBytesSync());
    if (image != null) {
      croppedFile = await ImageCropper.cropImage(
          cropStyle: CropStyle.circle,
          sourcePath: image.path,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
    }
    await _serverCommunication.uploadProfilePic(croppedFile).then((_) {});
  }

  Future<List<dynamic>> _getTimeline(int count, bool refresh) async {
    var result;
    await _serverCommunication
        .getPrivateTimeline(count, refresh, widget.username)
        .then((callback) {
      result = callback;
      mostRecent = getRecentActivity();
    });
    return result;
  }

  Future _refreshActivities() async {
    setState(() {
      counter++;
      _activities = _getTimeline(counter, false);
    });
    return null;
  }

  Future _reloadActivities() async {
    var temp;
    await getProfileInfo().then((onValue) {
      temp = onValue;
    });
    setState(() {
      _liked.clear();
      listHasNotBeenBuilt = true;
      counter = 1;
      //profileInfo = null;
      //mostRecent = null;
      profileInfo = Future.delayed(const Duration(milliseconds: 100), () {
        return temp;
      });
      //profileInfo = getProfileInfo();
      //_activities = null;
      _activities = _getTimeline(counter, true);
    });
    return null;
  }

  List<Icon> _starsForRatings(rating) {
    List<Icon> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < rating) {
        stars.add(Icon(Icons.star, color: Colors.yellow));
      } else
        stars.add(Icon(Icons.star));
    }
    return stars;
  }

  String numOf(List list) {
    int len = list.length;
    return "$len";
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

  Future<ProfileInfo> getProfileInfo() async {
    print("GETTING PROFILE INFO");
    return await _serverCommunication.profileInfo(
        widget.username, widget.userID);
  }

  Future<List> getRecentActivity() async {
    print("GETTING RECENT ACTIVITY");
    return await _serverCommunication.fourLatest();
  }

  void followButtonPressed(bool followPress) {
    print("CALLING FOLLOW OR UNFOLLOW USER!!!!!!");
    if (followPress)
      _serverCommunication.unfollowUser(widget.userID);
    else
      _serverCommunication.followUser(widget.userID);
  }

  changeText() {
    if (textHolder == "Follow") {
      setState(() {
        textHolder = "Unfollow";
        followButtonPressed(pressedFollow);
        pressedFollow = !pressedFollow;
        mostRecent = null;
        _activities = null;
        //isFollowing = _followingOrNot();
      });
    } else {
      setState(() {
        pressedFollow = !pressedFollow;
        followButtonPressed(pressedFollow);
        textHolder = "Follow";
        mostRecent = null;
        _activities = null;
        //isFollowing = _followingOrNot();
      });
    }
  }

  Widget _header(int reviewsTXT, int followersTXT, int followingsTXT,
      ProfileInfo profInfo) {
    String username = widget.username;
    return StickyHeader(
      overlapHeaders: true,
      header: Container(
        padding: const EdgeInsets.only(top: 0.0, left: 10, right: 10),
        height: 40.0,
        color: Colors.redAccent, //Colors.redAccent[400],
        //padding: EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.centerLeft,
        child: Row(
          children: <Widget>[
            Text("$username",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            Spacer(),
            ButtonTheme(
                minWidth: 30.0,
                height: 28.0,
                child: RaisedButton(
                    color: Colors.black,
                    child: widget.username == auth.usernameLOGGEDIN
                        ? Text('Logout', style: TextStyle(color: Colors.grey))
                        : Text('$textHolder',
                            style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      if (widget.username == auth.usernameLOGGEDIN) {
                        _auth.logout().then((_) => Navigator.of(context)
                            .pushReplacementNamed('/login'));
                      } else if (pressedFollow) {
                        followButtonPressed(pressedFollow);
                        pressedFollow = !pressedFollow;
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  new Profile(username, widget.userID, 0, 0, 0),
                              fullscreenDialog: true,
                            ));
                      } else {
                        print("pressed follow");

                        followButtonPressed(pressedFollow);
                        pressedFollow = !pressedFollow;
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  new Profile(username, widget.userID, 0, 0, 0),
                              fullscreenDialog: true,
                            ));
                      }
                    }))
          ],
        ),
      ),
      content: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.redAccent, Colors.black],
                stops: [0.2, 1])),

        padding: const EdgeInsets.only(top: 55.0, left: 10, right: 10),
        //color: Colors.grey[300],
        child: new Column(
          children: <Widget>[
            // Row with prof.pic, followers and post numbers
            Row(
              //crossAxisAlignment: Cross AxisAlignment.stretch,

              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    width: 100.0,
                    height: 86,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: profilePictureURL != null &&
                                  profilePictureURL != ""
                              ? NetworkImage(profilePictureURL)
                              : AssetImage('images/logoTRANS.png'),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(65.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),

                    child: widget.username == auth.usernameLOGGEDIN
                        ? IconButton(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.zero,
                            iconSize: 28.0,
                            icon: Icon(Icons.add_a_photo),
                            onPressed: () {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.white,
                                content: Container(
                                  alignment: Alignment.center,
                                  height: 90,
                                  child: Column(
                                    children: <Widget>[
                                      //Divider(),
                                      GestureDetector(
                                        child: Text("From Camera",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25)),
                                        onTap:
                                            getImageCamera, //(){ print("CLICKADE PÅ CAMERA");},
                                      ),
                                      Divider(),
                                      GestureDetector(
                                        child: Text("From Gallery",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25)),
                                        onTap:
                                            getImageGallery, //(){ print("CLICKADE PÅ GALLERY");},
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              Scaffold.of(context).showSnackBar(snackBar);
                            }

                            //_addProfilePicture(),
                            )
                        : null, // NOT LOGGED IN, SO NOT SHOWING ADD PHOTO BUTTON
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            //Text("null", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey, decoration: TextDecoration.none)),
                            Text("$followersTXT",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                    decoration: TextDecoration.none)),

                            //Text("99", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey, decoration: TextDecoration.none)),
                            Text("Followers",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    decoration: TextDecoration
                                        .none)), //, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Text("$followingsTXT",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                    decoration: TextDecoration.none)),
                            Text("Following",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    decoration: TextDecoration
                                        .none)), //, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            //Text("$snapshot.data.reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey, decoration: TextDecoration.none));

                            Text("$reviewsTXT",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                    decoration: TextDecoration.none)),

                            //Text("$reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey, decoration: TextDecoration.none)),
                            Text("Reviews",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    decoration: TextDecoration
                                        .none)), //, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Row for recent activity (4 latest movies and given rating)

            FutureBuilder<dynamic>(
                future: mostRecent,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData || snapshot == null) {
                    //mostRecent = getRecentActivity();
                    //_serverCommunication.fourLatest();
                    //_recentActivity();

                    return Text(
                        "waiting for server"); //Center(child: CircularProgressIndicator());
                  }

                  print("RECENT ACTIVITY: " + snapshot.data.toString());
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10.0),
                      Text("Recent Activity",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                              decoration: TextDecoration.none)),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _recentActivity(snapshot.data),
                        ),
                      ),
                      Divider(color: Colors.black)
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  Image imageChecker(String url) {
    if (url == 'N/A' || url == 'null' || url == null) {
      return Image.asset('images/logoTRANS.png', height: 80);
    } else {
      return Image.network(url, height: 60);
    }
  }

  void _buildLiked(dynamic json) {
    if (listHasNotBeenBuilt) {
      print("Kommmer hit");
      for (var i = 0; i < json.length; i++) {
        List temp = json[i]['likers'];
        print("lista av likers");
        print(temp);
        for (var j = 0; j < temp.length; j++) {
          if (temp[j]['username'] == auth.usernameLOGGEDIN) {
            print("likead");
            print(json[i]['review_id']);
            _liked.add(json[i]['review_id']);
            temp.removeAt(j);
          }
        }
      }
      listHasNotBeenBuilt = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: FutureBuilder<dynamic>(
                future: profileInfo,
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  print("HEEEEEEEEEEEEEEEEEELOOOOOOOOOOOOOO");
                  String username = widget.username;
                  ProfileInfo profInfo = snapshot.data;
                  bool isFollowing = profInfo.getIsFollowing(profInfo);
                  pressedFollow = isFollowing;
                  int reviewsTXT = profInfo.getReviews(snapshot.data);
                  int followersTXT = profInfo.getFollowers(profInfo);
                  int followingsTXT = profInfo.getFollowing(profInfo);
                  profilePictureURL = profInfo.getProfPicURL(profInfo);

                  if (profInfo.getIsFollowing(profInfo)) {
                    textHolder = "Unfollow";
                  } else {
                    textHolder = "Follow";
                  }
                  if (_activities == null) {
                    /*Future.delayed(const Duration(milliseconds: 500), () {
                      print("_getTimeline");
                      _activities = _getTimeline(counter, true);
                    });*/
                    _activities = _getTimeline(counter, true);
                  }

                  print("Eller hur?");
                  return FutureBuilder<List<dynamic>>(
                      future: _activities,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<dynamic>> snapshot2) {
                        if (!snapshot2.hasData || snapshot2.data == null) {
                          return Center(child: CircularProgressIndicator());
                        }
                        print("BAABBABABBABA");
                        return Container(
                          child: Center(
                            child: RefreshIndicator(
                              onRefresh: _reloadActivities,
                              child: ListView.builder(
                                itemCount: snapshot2.data.length % 10 != 0
                                    ? (snapshot2.data.length + 1)
                                    : (snapshot2.data.length + 2),
                                itemBuilder: (context, index) {
                                  print(snapshot2.data.length);
                                  var _list = snapshot2.data;
                                  printWrapped(_list.toString());
                                  if (_list.length != 0) {
                                    _buildLiked(snapshot2.data);
                                  }
                                  if (index == 0) {
                                    return _header(reviewsTXT, followersTXT,
                                        followingsTXT, profInfo);
                                  } else if (index ==
                                      snapshot2.data.length + 1) {
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
                                    //int index - 1 = index - 1;
                                    return Container(
                                      alignment: Alignment.center,
                                      color: Colors.grey[100],
                                      child: Card(
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        elevation: 4,
                                        //shape: ShapeBorder.
                                        child: Container(
                                          //padding: const EdgeInsets.all(4.0),
                                          child: new Column(
                                            children: <Widget>[
                                              // User Details
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4,
                                                    right: 4,
                                                    top: 4,
                                                    bottom: 4),
                                                child: Row(
                                                  children: <Widget>[
                                                    // Här ska koden vara för bilden

                                                    Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          image: DecorationImage(
                                                              image: profilePictureURL !=
                                                                          null &&
                                                                      profilePictureURL !=
                                                                          ""
                                                                  ? NetworkImage(
                                                                      profilePictureURL)
                                                                  : AssetImage(
                                                                      'images/logoTRANS.png'),
                                                              fit:
                                                                  BoxFit.cover),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          65.0)),
                                                        )),

                                                    Text("  " + "$username",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Spacer(),
                                                  ],
                                                ),
                                              ),
                                              //Divider(),
                                              Container(
                                                //height: 200,
                                                //width:200,
                                                color: Colors.white,
                                                child: _list[index - 1]
                                                                ['img'] !=
                                                            null &&
                                                        _list[index - 1]
                                                                ['img'] !=
                                                            "null" &&
                                                        _list[index - 1]
                                                                ['img'] !=
                                                            ""
                                                    ? Image.network(
                                                        _list[index - 1]['img'],
                                                        fit: BoxFit.fitWidth,
                                                      )
                                                    : null, //Image.network('https://cdn.discordapp.com/attachments/300997774990639104/696797826243624990/logga2.png'),
                                              ),

                                              // FILM OCH RATING
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    /// POSTER FOR MOVIE IF EXISTING
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4,
                                                              right: 4),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: imageChecker(
                                                          _list[index - 1]
                                                              ['poster'],
                                                        ), //Image.network(filteredMovies[index].url, height: 80,),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 20,
                                                      child: Text(
                                                          (_list[index - 1][
                                                                      'title'] ==
                                                                  null
                                                              ? ""
                                                              : _list[index - 1]
                                                                  ['title']),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18)),
                                                    ),

                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: _starsForRatings(
                                                          _list[index - 1]
                                                                      [
                                                                      'rating'] ==
                                                                  null
                                                              ? 3.0
                                                              : double.parse(
                                                                  _list[index -
                                                                          1][
                                                                      'rating'])),
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.start,
                                                    direction: Axis.horizontal,
                                                    children: <Widget>[
                                                      RichText(
                                                          text: TextSpan(
                                                              style: DefaultTextStyle
                                                                      .of(
                                                                          context)
                                                                  .style,
                                                              children: <
                                                                  TextSpan>[
                                                            TextSpan(
                                                              text: "$username",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15),
                                                            ),
                                                            TextSpan(
                                                                text: " " +
                                                                    (_list[index - 1]['caption'] ==
                                                                            null
                                                                        ? ""
                                                                        : _list[index -
                                                                                1]
                                                                            [
                                                                            'caption']),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15)),
                                                          ])),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // ikoner för poppa, kommentera och dela
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  // pop knapp, comment knapp osv under bilden
                                                  GestureDetector(
                                                    child: Tab(
                                                        icon: _liked.contains(
                                                                _list[index - 1]
                                                                    [
                                                                    'review_id'])
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
                                                      print(_list[index - 1]
                                                          ['review_id']);
                                                      _pressed(_list[index - 1]
                                                          ['review_id']);
                                                      /*int curr = int.parse(
                                                          _list[index - 1]
                                                              ['likers']);

                                                      _list[index - 1]['likers'] =
                                                          curr++; */ // DOESNT WORK, WE NEED TO CREATE A NEW CLASS AND INTRODUCE GETTERS/SETTERS
                                                    },
                                                  ),
                                                  Text(
                                                      _list[index - 1]
                                                                  ['likers'] ==
                                                              null
                                                          ? "0"
                                                          : _liked.contains(_list[
                                                                      index - 1]
                                                                  ['review_id'])
                                                              ? (_list[index - 1]['likers']
                                                                          .length +
                                                                      1)
                                                                  .toString()
                                                              : _list[index - 1]
                                                                      ['likers']
                                                                  .length
                                                                  .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: GestureDetector(
                                                        child: Tab(
                                                            icon: Image.asset(
                                                          "images/commentICON.png",
                                                          width: 40,
                                                          height: 40,
                                                        )),
                                                        onTap: () => Navigator.push(
                                                            context,
                                                            MaterialPageRoute<
                                                                    dynamic>(
                                                                builder: (context) => new Comments(
                                                                    _list[index -
                                                                            1][
                                                                        'review_id'],
                                                                    _list[index -
                                                                            1][
                                                                        'comments'])))),
                                                  ),
/*
                                      IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 28.0,
                                          icon: Icon(Icons.chat_bubble_outline),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute<dynamic>(
                                                  builder: (context) => new Comments(
                                                      _list[index]['review_id'],
                                                      _list[index][
                                                          'comments']))) //() => showSnackbar(context, 'Share'),
                                          ),
                                          */
                                                  Text(
                                                      numOf(_list[index - 1][
                                                                  'comments'] ==
                                                              null
                                                          ? []
                                                          : _list[index - 1]
                                                              ['comments']),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18)),
                                                  Spacer(),

                                                  Spacer(),
                                                  Spacer(),
                                                ],
                                              ),

                                              // Kommentarer

                                              // time stamp
                                              Text(
                                                _list[index - 1]
                                                            ['time_stamp'] ==
                                                        null
                                                    ? "00:00"
                                                    : _list[index - 1]
                                                        ['time_stamp'],
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11),
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
                        );
                      });
                })));
  }
}
