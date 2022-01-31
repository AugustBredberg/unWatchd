import 'package:flutter/material.dart';
import 'package:un_watchd/screens/home/comments.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/services/auth.dart' as auth;
import 'dart:async';

class SingleReview extends StatefulWidget {
  int reviewID;
  var overlayFromNotifications;

  SingleReview(revID, overlay) {
    reviewID = revID;
    overlayFromNotifications = overlay;
  }

  @override
  _SingleReviewState createState() => _SingleReviewState();
}

class _SingleReviewState extends State<SingleReview> {
  Future<dynamic> _review;
  ServerCommunication _serverCommunication = ServerCommunication();

  bool listHasNotBeenBuilt = true;
  bool _liked = false;
  @override
  void initState() {
    super.initState();
    _review = _getReview(widget.reviewID);
  }

  Future<dynamic> _getReview(int reviewID) async {
    return await _serverCommunication.getReviewFromID(reviewID);
  }

  void _pressed(int review_id) {
    setState(() {
      if (_liked) {
        _serverCommunication.unlike(review_id);
        _liked = false;
      } else {
        _serverCommunication.like(review_id);
        _liked = true;
      }
    });
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

  Image imageChecker(String url) {
    print("URL:");
    print(url);
    if (url == 'N/A' || url == null || url == 'null') {
      return Image.asset('images/logoTRANS.png', height: 80);
    } else {
      return Image.network(url, height: 60);
    }
  }

  void _buildLiked(List<dynamic> json) {
    if (listHasNotBeenBuilt) {
      print("Kommmer hit");
      for (var i = 0; i < json.length; i++) {
        if (json[i]['username'] == auth.usernameLOGGEDIN) {
          print("likead");
          _liked = true;
          json.removeAt(i);
        }
      }
      listHasNotBeenBuilt = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _review,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData) {
          return Container(
              height: 300, child: Center(child: CircularProgressIndicator()));
        }
        //checking if liked
        //bool liked = false;

        String username = snapshot.data['username'];
        String title = snapshot.data['title'];
        String caption = snapshot.data['comment'];
        if (caption.length > 50) caption = caption.substring(0, 50) + "...";
        double rating = 3;
        var likes = snapshot.data['likers'];
        print(likes);
        _buildLiked(likes);
        int comments = snapshot.data['comments'].length;
        List<dynamic> allComments = snapshot.data['comments'];
        String timestamp = snapshot.data['time_stamp'];
        String reviewImgURL = snapshot.data['img'];
        String posterUrl = snapshot.data['poster'];
        String profPicUrl = snapshot.data['profile_pic'];
        print("REVIEW BBABAABABABA");
        print(reviewImgURL.toString());
        return Container(
          height: 800,
          width: 400,
          //padding: const EdgeInsets.only(top:25.0),
          child: new Column(
            children: <Widget>[
              // User Details
              Padding(
                padding:
                    const EdgeInsets.only(left: 4, right: 4, top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    profPicUrl != "" ||
                            profPicUrl != "null" ||
                            profPicUrl != null
                        ? Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(profPicUrl),
                                  fit: BoxFit.cover),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(65.0)),
                            ))
                        : null,
                    Text("  $username",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                    Spacer(),
                  ],
                ),
              ),
              //Divider(),
              Container(
                //height: 200,
                //width:200,
                color: Colors.white,
                child: //Image.asset("images/logoTRANS.png",fit: BoxFit.fitWidth,),
                    reviewImgURL != "" &&
                            reviewImgURL != "null" &&
                            reviewImgURL != null
                        ? Image.network(reviewImgURL, fit: BoxFit.fitWidth)
                        : null,
              ),

              // FILM OCH RATING
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    /// POSTER FOR MOVIE IF EXISTING
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: imageChecker(
                            posterUrl), //Image.network(filteredMovies[index].url, height: 80,),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 20,
                      child: Text("$title",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black)),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _starsForRatings(rating),
                    ),
                  ],
                ),
              ),

              // Caption
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                //padding: const EdgeInsets.only(left: 4, right: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Text(
                        "$username ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      Text("$caption",
                          style: TextStyle(fontSize: 16, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              // ikoner för poppa, kommentera och dela
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // pop knapp, comment knapp osv under bilden
                  GestureDetector(
                    child: Tab(
                        icon: _liked
                            ? Image.asset(
                                "images/popped.jpg",
                                width: 40,
                                height: 40,
                              )
                            : Image.asset(
                                "images/unpopped.jpg",
                                width: 40,
                                height: 35,
                              )),
                    onTap: () {
                      _pressed(widget.reviewID);
                    },
                  ),
                  Text(
                      likes == null
                          ? "0"
                          : _liked
                              ? (likes.length + 1).toString()
                              : likes.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),

                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: GestureDetector(
                        child: Tab(
                            icon: Image.asset(
                          "images/commentICON.png",
                          width: 40,
                          height: 40,
                        )),
                        onTap: () {
                          widget.overlayFromNotifications.remove();
                          Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                  builder: (context) => new Comments(
                                      widget.reviewID, allComments)));
                        }),
                  ),
                  Text("$comments",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Spacer(),

                  Spacer(),
                  Spacer(),
                ],
              ),

              // Kommentarer

              // time stamp
              Text(
                "$timestamp",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
