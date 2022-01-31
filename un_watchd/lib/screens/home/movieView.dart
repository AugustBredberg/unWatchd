import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:un_watchd/models/extraInfo.dart';
import 'package:un_watchd/screens/home/post.dart';

class MovieView extends StatelessWidget {
  String title;
  String year;
  String imdb_id;
  String url;
  List<Widget> movieList;
  ExtraInfo xtra;

  MovieView(title, year, imdb_id, url, xtra) {
    this.title = title;
    this.year = year;
    this.imdb_id = imdb_id;
    this.url = url;
    this.xtra = xtra;
  }

  Image imageChecker() {
    if (url == 'N/A') {
      return Image.asset('images/logoTRANS.png', width: 250, height: 250);
    } else {
      return Image.network(
        url,
        height: 250,
        width: 200,
      );
    }
  }

  String movieChecker() {
    if (this.xtra.type == 'movie') {
      return 'Movie';
    } else if (this.xtra.type == 'series') {
      return 'Series';
    } else {
      return this.xtra.type;
    }
  }

  String noInfo(String input) {
    if (input == 'N/A') {
      return 'Nothing to show';
    } else {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.0),
        child: AppBar(
          title: SafeArea(
            child: Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white)),
          ),
          backgroundColor: Colors.grey[800],
        ),
      ),
      body: Scaffold(
        backgroundColor: Colors.grey[800],
        body: SingleChildScrollView(
          child: new Container(
            alignment: Alignment.topLeft,
            //  height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.grey[800],
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 4.0,
                  ),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        imageChecker(),
                        SizedBox(width: 8.0),
                        //Column(
                        //children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 20,
                          child: Container(
                            height: 250,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text.rich(
                                  TextSpan(
                                    text: 'Title:  ',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color:
                                            Colors.white), // default text style
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: title,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: 'Year:  ',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color:
                                            Colors.white), // default text style
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: year,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: 'Genre:  ',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color:
                                            Colors.white), // default text style
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: noInfo(this.xtra.genre),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: 'Director:  ',
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        color:
                                            Colors.white), // default text style
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: noInfo(this.xtra.director),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                                Text(movieChecker(),
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                      ]),
                  SizedBox(height: 8.0),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  SizedBox(height: 5.0),
                  Text.rich(
                    TextSpan(
                      text: 'IMDB-rating:  ',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white), // default text style
                      children: <TextSpan>[
                        TextSpan(
                            text: noInfo(this.xtra.imdbRating),
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal))
                      ],
                    ),
                  ),

                  SizedBox(height: 5.0),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  SizedBox(height: 5.0),
                  //Flexible text som förklarar ploten

                  Text.rich(
                    TextSpan(
                      text: 'Plot:\n',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white), // default text style
                      children: <TextSpan>[
                        TextSpan(
                            text: noInfo(this.xtra.plot),
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal))
                      ],
                    ),
                  ),

                  SizedBox(height: 5.0),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  SizedBox(height: 5.0),

                  Text.rich(
                    TextSpan(
                      text: 'Actors:\n',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white), // default text style
                      children: <TextSpan>[
                        TextSpan(
                            text: noInfo(this.xtra.actors),
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal))
                      ],
                    ),
                  ),

                  SizedBox(height: 5.0),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  SizedBox(height: 5.0),

                  Text.rich(
                    TextSpan(
                      text: 'Awards:\n',
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white), // default text style
                      children: <TextSpan>[
                        TextSpan(
                            text: noInfo(this.xtra.awards),
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.normal))
                      ],
                    ),
                  ),

                  SizedBox(height: 5.0),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  SizedBox(height: 5.0),

                  Align(
                    alignment: Alignment.center,
                    child: FlatButton(
                      color: Colors.red[700],
                      textColor: Colors.white,
                      disabledColor: Colors.grey,
                      disabledTextColor: Colors.black,
                      padding: EdgeInsets.all(8.0),
                      splashColor: Colors.redAccent,
                      onPressed: () {
                        /*Här skickas imdb_id med för att starta en review där denna film redan är vald*/
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new Post(title, url)),
                        );
                      },
                      child: Text(
                        "Review",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  //SizedBox(height: 5.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
