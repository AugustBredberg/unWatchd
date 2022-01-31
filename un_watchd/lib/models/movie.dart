class Movie {
  String title;
  String year;
  String imdb_id;
  String url;
  String rating;
  
  Movie(Map <String, dynamic> data){
    title = data['title'];
    year = data['year'];
    imdb_id = data['imdb_id'];
    url = data['poster'];
    rating = data['unwatchd_average'];
  }

}
