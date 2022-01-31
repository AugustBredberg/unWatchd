class User {

  String username;
  int uid;
  bool success;
  String profPicURL;

    User(String user, int userID, bool successBool, String url){
    username = user;
    uid = userID;
    success = successBool;
    profPicURL = url;
  }

}