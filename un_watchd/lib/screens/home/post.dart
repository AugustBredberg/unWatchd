import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:un_watchd/services/serverCom.dart';
import 'package:un_watchd/models/movie.dart';
import 'package:un_watchd/screens/home/movieTextField.dart';
import 'package:un_watchd/screens/home/movieTextField.dart' as movieAcceptable;

class Post extends StatefulWidget {
  String movie;
  String posterURL;
  Post(String movie, String url) {
    this.movie = movie;
    this.posterURL = url;
  }
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  final ServerCommunication _serverCom = ServerCommunication();
  final _formKey = GlobalKey<FormState>();
  String _error = '';
  bool movieChosen = false;

  final FocusNode _focusNode = FocusNode();
  String _movie = '';
  double _rating = 0;
  String _caption = '';
  List<Movie> filteredMovies;
  //final BuildContext textFieldContext = ;

  File _image;
  OverlayEntry _overlayEntry;

  OverlayEntry _createOverlayEntry() {
    /*RenderBox renderBox = context.findRenderObject();
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);*/
    return OverlayEntry(
        builder: (context) => Positioned(
              left: 50,
              //offset.dx,
              top: 250, //offset.dy + size.height + 5.0,
              width: 250, //size.width,
              child: Material(
                elevation: 4.0,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: <Widget>[
                    ListTile(
                      title: Text('Syria'),
                    ),
                    ListTile(
                      title: Text('Lebanon'),
                    )
                  ],
                ),
              ),
            ));
  }

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
  }

  getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    File croppedFile;
    //File result;

    print(image.readAsBytesSync());
    if (image != null) {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          /*aspectRatioPresets: [
            CropAspectRatioPreset.ratio16x9,
          ],*/
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
    }

    setState(() {
      print("i setstate");
      _image = croppedFile;
    });
  }

  getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    File croppedFile;
    //File result;
    try {
      print(image.readAsBytesSync());
    } catch (e) {
      print("image was null");
      return;
    }
    if (image != null) {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          /*aspectRatioPresets: [
            
            CropAspectRatioPreset.square,
          ],*/

          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
    }
    setState(() {
      print("i setstate");
      _image = croppedFile; //croppedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed('/home'),
          )),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20.0),
                Column(
                  children: <Widget>[
                    Container(
                      height: _image == null ? 20 : 100,
                      child: _image == null
                          ? Text('No image selected.')
                          : Image.file(_image),
                    ),
                    SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ButtonTheme(
                              height: 44,
                              child: RaisedButton(
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                ),
                                onPressed: getImageCamera,
                              )),
                          SizedBox(width: 20),
                          ButtonTheme(
                              height: 44,
                              child: RaisedButton(
                                color: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.0),
                                ),
                                child: Icon(
                                  Icons.perm_media,
                                  color: Colors.white,
                                ),
                                onPressed: getImageGallery,
                              )),
                        ]),
                  ],
                ),
                SizedBox(height: 20.0),
                new MovieField(widget.movie, widget.posterURL),
                SizedBox(height: 20.0),
                RatingBar(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() => _rating = rating);
                    print(rating);
                  },
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  decoration: new InputDecoration(
                      labelText: "Caption",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      )),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  validator: (val) => val.isEmpty ? 'Enter a caption' : null,
                  onChanged: (val) {
                    setState(() => _caption = val);
                  },
                ),
                SizedBox(height: 12.0),
                ButtonTheme(
                  height: 44,
                  child: RaisedButton(
                      color: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        print("AJAJAJAJAJ HÄR HAR VI::::: " +
                            movieAcceptable.movieChosenAcceptable.toString());
                        if (movieAcceptable.movieChosenAcceptable) {
                          if (_formKey.currentState.validate()) {
                            print(_movie);
                            _serverCom
                                .upload(_image, movieAcceptable.movieChosen,
                                    _rating, _caption)
                                .then((result) {
                              if (result) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              } else {
                                setState(() => _error = 'Upload failed');
                              }
                            });
                          }
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Chosen movie is not supported",
                                      style: TextStyle(fontSize: 20)),
                                  content: Text(
                                      "Search and choose a supported movie"),
                                );
                              });
                        }
                      }),
                ),
                Text(
                  _error,
                  style: TextStyle(color: Colors.red, fontSize: 14.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
