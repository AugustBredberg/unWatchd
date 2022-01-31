class ExtraInfo{
  String title;
  String year;
  String type;
  String actors;
  String awards;
  String genre;
  String director;
  String imdbRating;
  String plot;


  ExtraInfo(Map <String, dynamic> data){
    title = data['title'];
    year = data['year'];
    type = data['type'];
    actors = data['actors'];
    awards = data['awards'];
    genre = data['genre'];
    director = data['director'];
    imdbRating = data['imdb_rating'];
    plot = data['plot'];
  }

}
