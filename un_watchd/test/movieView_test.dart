// Import the test package and Counter class
import 'package:flutter_test/flutter_test.dart';
import 'package:un_watchd/models/extraInfo.dart';
import 'package:un_watchd/screens/home/movieView.dart';
import 'package:flutter/material.dart';

void main() {
  test('Movie', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": "movie"
    };

    final mv = MovieView('Shrek', '1969', 'k34htg3', 'www.kyckling.com',
        new ExtraInfo(moreData));

    var output = mv.movieChecker();
    expect(output, 'Movie');
  });
  test('Series', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": "series"
    };

    final mv = MovieView('Shrek', '1969', 'k34htg3', 'www.kyckling.com',
        new ExtraInfo(moreData));

    var output = mv.movieChecker();
    expect(output, 'Series');
  });
  test('If Movie/Series == ', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": 'N/A'
    };

    final mv = MovieView('Shrek', '1969', 'k34htg3', 'www.kyckling.com',
        new ExtraInfo(moreData));

    var output = mv.movieChecker();
    expect(output, 'N/A');
  });
  test('noInfo true', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": 'N/A'
    };

    final mv = MovieView('Shrek', '1969', 'k34htg3', 'www.kyckling.com',
        new ExtraInfo(moreData));
    String compare = 'N/A';
    var output = mv.noInfo(compare);
    expect(output, 'Nothing to show');
  });
  test('noInfo false', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": 'N/A'
    };

    final mv = MovieView('Shrek', '1969', 'k34htg3', 'www.kyckling.com',
        new ExtraInfo(moreData));
    String compare = '...Information...';
    var output = mv.noInfo(compare);
    expect(output, '...Information...');
  });
  test('ImageChecker true', () {
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": 'N/A'
    };

    final mv = MovieView(
        'Shrek',
        '1969',
        'k34htg3',
        'http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/test1.jpeg',
        new ExtraInfo(moreData));
    var output = mv.imageChecker();
    var img = Image.network(
        'http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/test1.jpeg',
        width: 250,
        height: 250);
    expect(output.height, img.height);
  });
  test('ImageChecker false', () {
    //lägg till en äkta url bild
    Map<String, dynamic> moreData = {
      "title": 'Sweeney Todd',
      "year": '1999',
      "type": 'N/A'
    };

    final mv =
        MovieView('Shrek', '1969', 'k34htg3', 'N/A', new ExtraInfo(moreData));
    var output = mv.imageChecker();
    var img = Image.asset('images/logoTRANS.png', width: 250, height: 250);
    expect(output.height, img.height);
    expect(output.width, img.width);
  });
}
