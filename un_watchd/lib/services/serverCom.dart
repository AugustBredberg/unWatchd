import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:un_watchd/main.dart' as main;
import 'package:un_watchd/services/auth.dart' as auth;
import 'package:un_watchd/models/user.dart';
import 'package:un_watchd/models/movie.dart';
import 'package:un_watchd/models/extraInfo.dart';
import 'package:un_watchd/models/profileInfo.dart';

var prevFeed = [];

class ServerCommunication {
  // PRINTS WHOLE STRING
  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  Future<ExtraInfo> sendExtra(String imdb_id) async {
    bool cont = true;
    var movies;
    String str = "";

    main.socket.write('MORE INFO {"imdb_ID":"$imdb_id"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        print(dataString);
        var parsedData = JsonDecoder().convert(str);
        movies = parsedData;
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting");
      });
    }
    stream.cancel();
    print(movies['director']);
    ExtraInfo xtraInfo = new ExtraInfo(movies);
    print(xtraInfo.director);
    return xtraInfo;
  }

  Future<List<User>> sendUsers(String input) async {
    bool cont = true;
    List<User> result = [];
    String usern;
    int userID;
    String url;
    bool findSuccess;
    String error;
    String str = "";
    main.socket.write('FIND USER {"username": "$input"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        usern = parsedData['username'];
        userID = parsedData['user_id'];
        findSuccess = parsedData['success'];
        url = parsedData['img'];
        error = parsedData['error'];
        print(error);
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print(usern);
        print("waiting");
      });
    }
    stream.cancel();
    print("USERS PROFPIC::::::::::::" + url);
    if (usern == null) {
      print("No users found");
    } else {
      //if(user.length >= 1){
      //for(int i = 0; i < users.length; i++){
      result.add(new User(usern, userID, findSuccess, url));
      //}
    }

    print(result);
    return result;
  }

  Future<List<Movie>> sendMovies(String input) async {
    bool cont = true;
    List<Movie> result = [];
    var movies;
    String str = '';
    main.socket.write('FIND MOVIE {"title": "$input"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        movies = parsedData['movies'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting");
      });
    }
    stream.cancel();

    for (int i = 0; i < movies.length; i++) {
      result.add(new Movie(movies[i]));
    }
    print(result);
    return result;
  }

  Future<dynamic> getPrivateTimeline(
      int counter, bool refresh, String username) async {
    bool cont = true;
    var feed;
    if (refresh && username == auth.usernameLOGGEDIN) {
      prevFeed.clear();
      main.socket.write('PRIVATE FEED {"index":1,"refresh":"True"}');
    } else if (username == auth.usernameLOGGEDIN) {
      main.socket.write('PRIVATE FEED {"index":$counter,"refresh":"False"}');
    } else if (refresh && username != auth.usernameLOGGEDIN) {
      prevFeed.clear();
      main.socket.write(
          'SPECIFIC FEED {"index":1,"refresh":"True", "username":"$username"}');
    } else {
      main.socket.write(
          'SPECIFIC FEED {"index":$counter,"refresh":"False", "username":"$username"}');
    }

    print('Private feed skickat');
    var parsedData;
    String str = "";
    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      print('Får event');
      String dataString = String.fromCharCodes(event);
      str += dataString;
      print("dataString");

      try {
        parsedData = JsonDecoder().convert(str);
        feed = parsedData['feed'];
        print('fått feed');
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    print('Streamen skapa');

    while (cont) {
      print("i while");
      await Future.delayed(const Duration(milliseconds: 1000), () {
        print("waiting PRIVATE FEED");
      });
    }
    print('Streamen klar');

    stream.cancel();
    //print(feed);
    print(feed);
    //if(prevFeed == null)
    prevFeed.addAll(feed);
    return prevFeed;
  }

  Future<dynamic> getTimeline(int counter, bool refresh) async {
    bool cont = true;
    var feed;
    if (refresh) {
      prevFeed.clear();
      main.socket.write('HOME FEED {"index":1,"refresh":"True"}');
    } else {
      main.socket.write('HOME FEED {"index":$counter,"refresh":"False"}');
    }

    print('Home feed skickat');
    var parsedData;
    String str = "";
    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      print('Får event');
      String dataString = String.fromCharCodes(event);
      str += dataString;
      print("dataString");

      try {
        parsedData = JsonDecoder().convert(str);
        feed = parsedData['feed'];
        print('fått feed');
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    print('Streamen skapa');

    while (cont) {
      print("i while");
      await Future.delayed(const Duration(milliseconds: 1000), () {
        print("waiting GET TIMELINE");
      });
    }
    print('Streamen klar');

    stream.cancel();
    //print(feed);
    print(feed);
    try {
      prevFeed.addAll(feed);
    } catch (e) {
      print('Feed was null');
    }
    return prevFeed;
  }

  Future<bool> upload(
      File img, String movie, double rating, String caption) async {
    String url;
    String imdbId;
    String str = "";
    String poster = "";
    var cont = true;
    print("movie: " + movie);
    main.socket.write('FIND MOVIE {"title": "$movie"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      //var parsedData = JsonDecoder().convert(dataString);
      str += dataString;
      print("dataString");

      try {
        var parsedData = JsonDecoder().convert(str);
        var movies = parsedData['movies'];
        var tempM = movies[0];
        imdbId = tempM['imdb_id'];
        movie = tempM['title'];
        poster = tempM['poster'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting");
      });
    }

    stream.cancel();
    print("film hittad");
    // If an image is included
    if (img != null) {
      RandomAccessFile tempFile = await img.open(mode: FileMode.read);
      int size = tempFile.lengthSync();
      Uint8List fileAsBytes = await tempFile.read(size);
      String base64 = base64Encode(fileAsBytes);
      var tempSize = base64.length;
      String str = "";
      
      main.socket.write('UPLOAD PIC {"size": $tempSize, "type":"jpg"}');
      main.socket.write(base64);

      bool contin = true;
      var parsedData;

      StreamSubscription<Uint8List> streamTest =
          main.socketStream.listen((Uint8List event) {
        String dataString = String.fromCharCodes(event);
        str += dataString;
        try {
          parsedData = JsonDecoder().convert(str);
          url = parsedData['url'];
          contin = false;
        } catch (e) {
          print("Continue listening");
        }
      });

      while (contin) {
        print("fast");
        await Future.delayed(const Duration(milliseconds: 500), () {
          print("waiting");
        });
      }
      tempFile.closeSync();

      streamTest.cancel();
    }

    print(imdbId);
    print(movie);
    print(caption);
    print(rating);
    print(url);
    // får invalid arguments
    main.socket.write(
        'REVIEW {"IMDB_id":"$imdbId", "title": "$movie", "comment":"$caption", "rating":$rating, "img":"$url", "poster":"$poster"}');

    // Om upplägg misslyckas, skicka till servern att ta bort inlägget!

    bool c = true;
    StreamSubscription<Uint8List> streamT =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      print(dataString);
      c = false;
    });

    while (c) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting");
      });
    }

    streamT.cancel();
    return true;
  }

  Future<bool> uploadProfilePic(File img) async {
    String url;
    //var cont = true;
    print("IN SERVERCOM, uploadProfilePic");

    // If an image is included
    if (img != null) {
      RandomAccessFile tempFile = await img.open(mode: FileMode.read);
      int size = tempFile.lengthSync();
      Uint8List fileAsBytes = await tempFile.read(size);
      String base64 = base64Encode(fileAsBytes);
      var tempSize = base64.length;

      main.socket.write('UPLOAD PIC {"size": $tempSize, "type":"jpg"}');

      main.socket.write(base64);

      bool contin = true;
      var parsedData;
      String str = "";
      StreamSubscription<Uint8List> streamTest =
          main.socketStream.listen((Uint8List event) {
        String dataString = String.fromCharCodes(event);
        str += dataString;
        try {
          parsedData = JsonDecoder().convert(str);
          url = parsedData['url'];
          contin = false;
        } catch (e) {
          print("Continue listening");
        }
      });

      while (contin) {
        print("fast");
        await Future.delayed(const Duration(milliseconds: 500), () {
          print("waiting");
        });
      }
      tempFile.closeSync();

      streamTest.cancel();
    }
    //////// TRYING TO UPLOAD PROFILE PICTURE WITH URL
    try {
      print(url);
      main.socket.write('ADD PROFILE PIC {"url":"$url"}');
      return true;
    } catch (e) {
      print("UPLOAD PIC FAILED:::::::::::::::::: no URL recieved");
      return false;
    }
  }

  Future<List<Movie>> getAccountInfo(String input) async {
    bool cont = true;
    List<Movie> result = [];
    String str = "";
    var movies;

    main.socket.write('FIND MOVIE {"title": "$input"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        movies = parsedData['movies'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting ACCOUNT INFO");
      });
    }
    stream.cancel();

    for (int i = 0; i < movies.length; i++) {
      result.add(new Movie(movies[i]));
    }
    print(result);
    return result;
  }

  void followUser(int input) async {
    print(input);
    main.socket.write('FOLLOW {"user_id": $input}');
  }

  void unfollowUser(int input) async {
    print(input);
    main.socket.write('UNFOLLOW {"user_id": $input}');
  }

  Future<bool> isFollowing(int input) async {
    bool cont = true;
    //bool result;
    String str = "";
    bool success;
    print(input);
    if (input == 0 || input == null) return false;
    main.socket.write('IS FOLLOWED {"user_id": $input}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);

        success = parsedData['followed'];
        print("in isFollowing success: " + parsedData.toString());
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting ISFOLLOWING");
      });
    }
    stream.cancel();

    print("is following: " + success.toString());
    if (success == null) return false;
    return success;
  }

  void like(int review_id) async {
    bool cont = true;
    String str = "";
    main.socket.write('LIKE {"review_id":$review_id}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        print(parsedData);
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting like");
      });
    }
    stream.cancel();
  }

  void unlike(int review_id) async {
    main.socket.write('UNLIKE {"review_id":$review_id}');
  }

  void listening() {
    main.socket.write("LISTENING");
  }

  void stop_listening() {
    main.socket.write("STOP LISTENING");
  }

  Future<int> getMyFollowersInt(String username) async {
    bool cont = true;
    List<int> result = [];
    String str = "";
    var followers;

    main.socket.write('FOLLOWERS {"username":"$username"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        print("" + dataString);
        followers = parsedData['followers'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting getMyFollowersInt");
      });
    }
    stream.cancel();

    if (followers == null) return 0;
    for (int i = 0; i < followers.length; i++) {
      result.add(followers[i]);
    }
    print(result);
    return result.length;
  }

  Future<int> getAccountsReviewsInt(String username) async {
    bool cont = true;
    int result;
    var reviews;
    String str = "";
    main.socket.write('GET REVIEWS {"username":"$username"}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        print("" + dataString);
        reviews = parsedData['reviews'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting getAccountReviewsInt");
      });
    }
    stream.cancel();

    if (reviews == null) return 0;
    result = reviews;
    print(result);
    return result;
  }

  Future<ProfileInfo> profileInfo(String username, int userID) async {
    bool cont = true;
    //ProfileInfo profile;

    bool isFollowing;
    int reviews;
    var followers;
    var following;
    String picURL;
    String str = "";

    /// GETTING IS FOLLOWED BOOL
    main.socket.write('GET PROFILE INFO {"user_id": $userID}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);

        isFollowing = parsedData['is_followed'];
        reviews = parsedData['reviews'];
        followers = parsedData['followers']; // LIST
        following = parsedData['followings']; // LIST
        picURL = parsedData['img'];

        print("in GET PROFILE INFO result: " +
            isFollowing.toString() +
            reviews.toString() +
            followers.toString() +
            following.toString() +
            picURL.toString());
        cont = false;
      } catch (e) {
        print(e.toString());
        print("Continue listeing");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting GET PROFILE INFO");
      });
    }
    stream.cancel();
    if (isFollowing == null) isFollowing = false;
    if (reviews == null)
      reviews = 888; //return new ProfileInfo(false, 0, 0, 0);
    if (followers == null) followers = [];
    if (following == null) following = [];
    if (picURL == null) picURL = "";
    return new ProfileInfo(
        isFollowing, reviews, followers.length, following.length, picURL);
  }

  Future<List<dynamic>> fourLatest() async {
    bool cont = true;
    String str = "";
    //ProfileInfo profile;
    List<dynamic> result = [];
    bool success;
    var latest;

    /// GETTING IS FOLLOWED BOOL
    main.socket.write('FOUR LATEST');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);

        success = parsedData['success'];
        latest = parsedData['movies']; // LIST

        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting FOUR LATEST");
      });
    }
    stream.cancel();
    if (success == null) success = false;
    if (latest == null) {
      latest = [];
      result = [];
    }

    for (int i = 0; i < latest.length; i++) {
      result.add(latest[i]);
    }
    print("RESULT OF FOUR LATEST::::::::::::::::. " + result.toString());
    //return new ProfileInfo(
    //   isFollowing, reviews, followers.length, following.length);
    return result;
  }

  Future<List<dynamic>> getNotifications() async {
    bool cont = true;
    List<dynamic> result = [];
    bool success;
    var notifications;
    String str = "";
    //var comments;
    //var follows;
    print("hejhejhej");
    main.socket.write('GET NOTIFICATIONS ');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;

      try {
        var parsedData = JsonDecoder().convert(str);
        print("NOTIFICATIONS::::::: " + dataString);
        success = parsedData['success'];
        notifications = parsedData['notifications'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });
    print("notifications: " + notifications.toString());

    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting GET NOTIFICATIONS");
      });
    }
    stream.cancel();

    if (success != null && success) {
      try {
        result = notifications;
      } catch (e) {
        print("NO NOTIFICATiONS, RETURNING FROM SERvERCOM");
        return [];
      }
    }
    print("result after get notif: " + result.toString());
    return result;
  }

  Future<dynamic> getReviewFromID(int reviewID) async {
    print("REVIEW INFO IN SERVERCOM");
    var cont = true;
    var review;
    bool success;
    var result;
    String str = "";

    main.socket.write('SINGLE REVIEW INFO {"review_id":$reviewID}');

    StreamSubscription<Uint8List> stream =
        main.socketStream.listen((Uint8List event) {
      String dataString = String.fromCharCodes(event);
      str += dataString;
      try {
        var parsedData = JsonDecoder().convert(str);
        print("NOTIFICATIONS::::::: " + dataString);
        success = parsedData['success'];
        review = parsedData['info'];
        cont = false;
      } catch (e) {
        print("Continue listening");
      }
    });
    while (cont) {
      await Future.delayed(const Duration(milliseconds: 500), () {
        print("waiting REVIEW INFO");
      });
    }
    stream.cancel();

    if (success != null && success) {
      try {
        result = review[0];
        print("REVIEW FROM ID::::: " + review.toString());
      } catch (e) {
        print("COULD NOT GET REVIEW, RETURNING WITH NULL");
        return null;
      }
    } else
      return null;
    return result;
  }
}
