class ProfileInfo {
  bool isFollowing;
  int reviews;
  int followers;
  int following;
  String picURL;

  ProfileInfo(bool isFol, int revs, int folls, int followings, String url) {
    isFollowing = isFol;
    reviews = revs;
    followers = folls;
    following = followings;
    picURL = url;
    print("IN PROFILEINFO CONSTRUCTOR: " +
        isFol.toString() +
        revs.toString() +
        folls.toString() +
        followings.toString() +
        picURL.toString());
  }

  bool getIsFollowing(ProfileInfo info) {
    return info.isFollowing;
  }

  void setIsFollowing(ProfileInfo info) {
    if (info.isFollowing)
      info.followers--;
    else
      info.followers++;
    info.isFollowing = !info.isFollowing;
  }

  int getReviews(ProfileInfo info) {
    return info.reviews;
  }

  int getFollowers(ProfileInfo info) {
    return info.followers;
  }

  int getFollowing(ProfileInfo info) {
    return info.following;
  }

  String getProfPicURL(ProfileInfo info) {
    return info.picURL;
  }
}
