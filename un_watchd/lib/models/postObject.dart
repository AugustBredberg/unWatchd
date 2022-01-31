class PostObject {
  String username;
  int user_id;
  String profile_img;
  String review_img;
  int review_id;
  String title;
  double rating;
  String likers;
  String caption;
  var comments;
  String time_stamp;

  PostObject(Map<String, dynamic> data) {
    title = data['title'];
    caption = data['caption'];
    rating = data['rating'].toDouble();
    time_stamp = data['time_stamp'];
    profile_img = data['profile_img'];
    review_img = data['review_img'];
    review_id = data['review_id'];
    username = data['username'];
    user_id = data['user_id'];
    likers = data['likers'];
    comments = data['comments'];
  }
}
