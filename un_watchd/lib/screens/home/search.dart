import 'package:flutter/material.dart';
import 'package:un_watchd/models/user.dart';
import 'package:un_watchd/screens/home/movieView.dart';
import 'package:un_watchd/screens/home/profile.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/models/movie.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

Image imageChecker(String url) {
  if (url == 'N/A') {
    return Image.asset('images/logoTRANS.png', height: 80);
  } else {
    return Image.network(url, height: 80, width: 80);
  }
}

String noInfo(String input) {
  if (input == 'N/A') {
    return 'N/A';
  } else {
    return input;
  }
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  List<Movie> listedMovies = List();
  List<Movie> filteredMovies = List();
  List<User> listedUsers = List();
  List<User> filteredUsers = List();
  static MyTab _tabMovie = new MyTab(
      title: "Movie",
      color: Colors.redAccent,
      icon: Icon(Icons.local_movies)); //Colors.red[700]
  static MyTab _tabUser = new MyTab(
      title: "User", color: Colors.redAccent, icon: Icon(Icons.account_circle));
  final List<MyTab> _tabs = [_tabMovie, _tabUser];
  final ServerCommunication _serverCommunication = ServerCommunication();
  int searched;

  MyTab _myHandler;
  TabController _controller;
  //TextEditingController _controllerText; //unused

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    //_controllerText = new TextEditingController();

    _myHandler = _tabs[0];
    _controller.addListener(_handleSelected);
    filteredMovies = [];
    filteredUsers = [];
  }

  void _handleSelected() {
    setState(() {
      _myHandler = _tabs[_controller.index];
    });
  }

  Widget _buildBar() {
    if (_myHandler.title == "Movie") {
      return new TextField(
        maxLength: 255,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.all(15.0),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          hintText: 'Search for a movie',
        ),
        onSubmitted: (string) {
          _serverCommunication.sendMovies(string).then((onValue) {
            filteredMovies.clear();
            searched = 1;
            for (int i = 0; i < onValue.length; i++) {
              filteredMovies.add(onValue[i]);
              print(filteredMovies[i].rating);
            }
            setState(() {});
          });
        },
      );
    } else {
      return new TextField(
          maxLength: 255,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.all(15.0),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(),
            hintText: 'Search for a user',
          ),
          onSubmitted: (string) {
            searched = 1;
            _serverCommunication.sendUsers(string).then((onValue) {
              filteredUsers.clear();
              for (int i = 0; i < onValue.length; i++) {
                filteredUsers.add(onValue[i]);
                print(filteredUsers[i].uid);
              }
              setState(() {});
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: _buildBar(),
        backgroundColor: _myHandler.color,
        bottom: new TabBar(
          controller: _controller,
          tabs: <Tab>[
            new Tab(
              icon: _tabs[0].icon,
            ),
            new Tab(
              icon: _tabs[1].icon,
            )
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          filteredMovies.length > 0
              ? ListView.builder(
                  // List of MOVIES in tab
                  padding: EdgeInsets.all(10.0),
                  itemCount: filteredMovies.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        print("onTap called.(movie) + add id" +
                            filteredMovies[index].imdb_id);
                        _serverCommunication
                            .sendExtra(filteredMovies[index].imdb_id)
                            .then((onValue) {
                          print(onValue.director);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new MovieView(
                                    filteredMovies[index].title,
                                    filteredMovies[index].year,
                                    filteredMovies[index].imdb_id,
                                    filteredMovies[index].url,
                                    onValue)),
                          );
                        });
                      },
                      child: Card(
                        child: Container(
                          //height: 100,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child:
                                        imageChecker(filteredMovies[index].url),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Flexible(
                                    fit: FlexFit.tight,
                                    flex: 20,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          index >= filteredMovies.length
                                              ? 'Tom'
                                              : filteredMovies[index].title,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          index >= filteredMovies.length
                                              ? 'Tom'
                                              : filteredMovies[index].year,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        'UNWATCHD-RATING',
                                        style: TextStyle(
                                          fontSize: 10.0,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        height: 0.5,
                                      ),
                                      Text(
                                        index >= filteredMovies.length
                                            ? 'Tom'
                                            : noInfo(
                                                filteredMovies[index].rating),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Center(
                  heightFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.only(top: 40),
                    color: Colors.white,
                    height: 300,
                    child: Text("No movies found",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.grey)),
                  ),
                ),
          filteredUsers.length > 0
              ? ListView.builder(
                  //List of USERS in tab
                  padding: EdgeInsets.all(10.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        print("onTap called.(user) + add id");
                        print("ALL USERS FOUND:" + filteredUsers.toString());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => new Profile(
                                  filteredUsers[0].username,
                                  filteredUsers[index].uid,
                                  0,
                                  0,
                                  0),
                              fullscreenDialog: true,
                            ));
                      },
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: filteredUsers[index].profPicURL !=
                                                  null &&
                                              filteredUsers[index].profPicURL !=
                                                  ""
                                          ? NetworkImage(
                                              filteredUsers[index].profPicURL)
                                          : AssetImage('images/logoTRANS.png'),
                                      fit: BoxFit.cover),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(65.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 30, left: 10),
                                child: filteredUsers.length == 0 && searched > 0
                                    ? Text("No users found")
                                    : Text(
                                        index < filteredUsers.length
                                            ? filteredUsers[index].username
                                            : 'Tom',
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : Center(
                  heightFactor: 1,
                  child: Container(
                    padding: const EdgeInsets.only(top: 40),
                    color: Colors.white,
                    height: 300,
                    child: Text("No users found",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.grey)),
                  ),
                ),
        ],
      ),
    );
  }
}

class MyTab {
  final String title;
  final Color color;
  final Icon icon;
  MyTab({
    this.title,
    this.color,
    this.icon,
  });
}
/*
Image imageChecker(String url) {
  if (url == 'N/A') {
    return Image.asset('images/logoTRANS.png', height: 80);
  } else {
    return Image.network(url, height: 80);
  }
}

String noInfo(String input) {
  if (input == 'N/A') {
    return 'N/A';
  } else {
    return input;
  }
}
*/
