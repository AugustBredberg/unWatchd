import 'package:flutter/material.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/models/movie.dart';

bool movieChosenAcceptable;
String movieChosen;

class MovieField extends StatefulWidget {
  String movie;
  String posterURL;
  MovieField(String movie, String poster) {
    this.movie = movie;
    this.posterURL = poster;
  }

  @override
  _MovieFieldState createState() => _MovieFieldState();
}

class _MovieFieldState extends State<MovieField> {
  final FocusNode _focusNode = FocusNode();
  List<Movie> filteredMovies = [];
  final ServerCommunication _serverCom = ServerCommunication();
  TextEditingController text = TextEditingController();
  OverlayEntry _overlayEntry;

  final LayerLink _layerLink = LayerLink();
  String _movie = '';
  Image poster;

  @override
  void initState() {
    super.initState();
    print("MOVIE FROM MOVIE VIEW ::::::: " + widget.movie);
    _movie = widget.movie;
    movieChosen = _movie;
    text.text = _movie;
    if (_movie == "")
      movieChosenAcceptable = false;
    else
      movieChosenAcceptable = true;
    print("POSTER url: " + widget.posterURL);
    poster = imageChecker(widget.posterURL);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
  }

  Image imageChecker(String url) {
    if (url == 'N/A') {
      this.poster = Image.asset('images/logoTRANS.png', height: 100);
      return this.poster;
    } else {
      this.poster = Image.network(url, height: 100, width: 80);
      return this.poster;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              height: 400,
              child: CompositedTransformFollower(
                link: this._layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height - 110.0),
                child: Material(
                  elevation: 4.0,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredMovies.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Row(
                          children: [
                            imageChecker(filteredMovies[index].url),
                            Flexible(
                                flex: 20,
                                child: Text(filteredMovies[index].title)),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            this.poster =
                                imageChecker(filteredMovies[index].url);
                            _movie = filteredMovies[index].title;
                            text.text = filteredMovies[index].title;
                            _focusNode.unfocus();
                            movieChosenAcceptable = true;
                            movieChosen = _movie;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        poster != null
            ? poster
            : Image.asset('images/logoTRANS.png', height: 100),
        Padding(padding: EdgeInsets.only(bottom: 10)),
        //Text("GURKGURKGURK"),
        CompositedTransformTarget(
          link: this._layerLink,
          child: TextFormField(
              //autofocus: true,
              controller: text,
              focusNode: this._focusNode,
              decoration: new InputDecoration(
                  labelText:
                      'Search for a movie', //widget.movie == '' ? 'Search for a movie' : _movie,
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  )),
              //validator: (val) =>
              //val.isEmpty && _movie == '' ? 'Enter a movie' : val = _movie,
              onChanged: (val) {
                if (val != _movie) {
                  //movieChosenAcceptable = false;
                }
                print("val: " + val);
                print(_movie);
                setState(() => val = _movie);
              },
              onFieldSubmitted: (string) {
                _serverCom.sendMovies(string).then((onValue) {
                  filteredMovies.clear();
                  for (int i = 0; i < onValue.length; i++) {
                    filteredMovies.add(onValue[i]);
                    print(filteredMovies[i].rating);
                    _focusNode.requestFocus();
                  }
                });
              }),
        ),
      ],
    );
  }
}
