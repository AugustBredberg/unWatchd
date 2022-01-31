import sys
import socket
import selectors
import types
import mysql.connector
import json
import omdb
import hashlib
import os
import binascii
import base64
import requests
import datetime
from PIL import Image

from omdb import OMDBClient# 
omdb.set_default('apikey', "351a6e9d")
mydb = mysql.connector.connect(
    host="ec2-13-49-72-142.eu-north-1.compute.amazonaws.com",
    user="root",
    passwd="Bossy56!",
    database="bossy"
)

sel = selectors.DefaultSelector()

def accept_wrapper(sock):
    conn, addr = sock.accept()  # Should be ready to read
    print("accepted connection from", addr)
    #conn.setblocking(False)
    data = types.SimpleNamespace(addr=addr, inb=b"", outb=b"", uploading=False, pic_data=b"", pic_size=0, pic_type="", user_id=None, username="", logged_in=False, home_feed=[], private_feed=[])
    events = selectors.EVENT_READ | selectors.EVENT_WRITE
    sel.register(conn, events, data=data)

def hash_password(password):
    """Hash a password for storing."""
    salt = hashlib.sha256(os.urandom(60)).hexdigest().encode('ascii')
    pwdhash = hashlib.pbkdf2_hmac('sha512', password.encode('utf-8'), salt, 100000)
    pwdhash = binascii.hexlify(pwdhash)
    return (salt + pwdhash).decode('ascii')

#-----------------VERIFY USER--------------------------------------------------------------

def verify_password(stored_password, provided_password):
    """Verify a stored password against one provided by user"""
    salt = stored_password[:64]
    stored_password = stored_password[64:]
    pwdhash = hashlib.pbkdf2_hmac('sha512', provided_password.encode('utf-8'), salt.encode('ascii'), 100000)
    pwdhash = binascii.hexlify(pwdhash).decode('ascii')
    return pwdhash == stored_password

def valid_account(username, email):
    try:
        valid_username = False
        valid_email = False
        
        my_cursor = mydb.cursor()
        sql = ("SELECT username FROM profiles WHERE username = %s")
        val = (username,)
        my_cursor.execute(sql,val)
        
        if my_cursor.fetchall() == []:
            valid_username = True
            
            my_cursor = mydb.cursor()
            sql = ("SELECT email FROM profiles WHERE email = %s")
            val = (email,)
            my_cursor.execute(sql,val)
            
        if my_cursor.fetchall() == []:
            valid_email = True
            
        if valid_username and valid_email:
            return True
        else:
            return False
    except:
        return False
        
def valid_login(username, password):
    valid_username = False;
    valid_password = False;

    try:
        my_cursor = mydb.cursor()
        sql = ("SELECT username FROM profiles WHERE username = %s")
        val = (username,)
        my_cursor.execute(sql,val)
        if (my_cursor.fetchall()) == []:
            valid_username = False
            return False
        
        my_cursor = mydb.cursor()
        sql = ("SELECT password FROM profiles WHERE username = %s")
        val = (username,)
        my_cursor.execute(sql,val)
        truePassword = my_cursor.fetchall()
        if verify_password(truePassword[0][0], password):
            return True
    except:
        return False
    
#----------------OTHER FUNCTIONS-----------------------------------------------------------

def find_movie(movie_title):
    movie_info = omdb.search(movie_title)
    if movie_info == []:
        movie_info = omdb.request(t=movie_title).json()
        try:
            return [{"title": movie_info['Title'], "year": movie_info['Year'], "type": movie_info['Type'],"imdb_id": movie_info['imdbID'], "poster":movie_info['Poster']}]
        except:
            return False
    else:
        movie_info_buffer = []
        for movies in movie_info:
            if(movies['type'] == "movie" or "series" or "episode"):
                movie_info_buffer.append(movies)
        return movie_info_buffer

def get_user_id(username):
    my_cursor = mydb.cursor()
    sql = ("SELECT id FROM profiles WHERE username = %s")
    val = (username,)

    my_cursor.execute(sql, val)
    user_id = my_cursor.fetchall()

    if (user_id == []):
        return False
    else:
        return user_id[0][0]
    
def get_comments(review_id):
    my_cursor = mydb.cursor()
    sql = ("SELECT comment, user_id FROM comments WHERE review_id = %s")
    val = str(review_id)

    my_cursor.execute(sql, val)
    comments = my_cursor.fetchall()

    if (comments == []):
        return []
    else:
        return comments
    

def get_followings(user_id): #no test written
    my_cursor = mydb.cursor()

    sql = ("SELECT user_id FROM followings WHERE following_id = %s")
    val = (user_id,)
    
    my_cursor.execute(sql, val)
    followers = my_cursor.fetchall()

    if (followers == []):
        return []
    else:
        followers_fixed_array = []
        for tuples in followers:     ## ändrar formen [(1,), (2,)] till [1, 2]
            followers_fixed_array.append(tuples[0])
        return followers_fixed_array

def get_followers(user_id): #no test written
    my_cursor = mydb.cursor()

    sql = ("SELECT following_id FROM followings WHERE user_id = %s")
    val = (user_id,)
    
    my_cursor.execute(sql, val)
    followings = my_cursor.fetchall()

    if (followings == []):
        return []
    else:
        followings_fixed_array = []
        for tuples in followings:     ## ändrar formen [(1,), (2,)] till [1, 2]
            followings_fixed_array.append(tuples[0])
        return followings_fixed_array

def get_nr_of_likes(review_id):
    my_cursor = mydb.cursor()
    sql = ("SELECT * FROM likes WHERE review_id = %s")
    val = (review_id,)

    my_cursor.execute(sql, val)
    nr_of_likes = len(my_cursor.fetchall())

    return nr_of_likes

def get_home_feed(user_id, sock):
    #try:        
        my_cursor = mydb.cursor()
        sql = "SELECT title,review_entry.comment AS caption,rating,profiles_review.img AS profile_img,review_entry.time_stamp,review_entry.img AS review_img,review_entry.review_id,review_entry.user_id,review_entry.username ,GROUP_CONCAT(DISTINCT CONCAT(profiles_like.username,'|<cplit,>|',likes.user_id) SEPARATOR '|<cplit>|') as 'likers', GROUP_CONCAT(DISTINCT CONCAT(comments.comment,'|<split,>|',profiles_comment.username,'|<split,>|',comments.user_id,'|<split,>|',profiles_comment.img,'|<split,>|',comments.time_stamp) SEPARATOR '|<split>|') AS 'comments' FROM review_entry LEFT JOIN likes ON likes.review_id = review_entry.review_id LEFT JOIN comments ON review_entry.review_id = comments.review_id LEFT JOIN profiles AS profiles_like ON profiles_like.id = likes.user_id LEFT JOIN profiles AS profiles_review ON profiles_review.id = review_entry.user_id LEFT JOIN profiles as profiles_comment ON profiles_comment.id = comments.user_id WHERE review_entry.user_id IN (SELECT following_id FROM followings WHERE user_id = %s) OR review_entry.user_id = %s GROUP BY review_entry.review_id ORDER BY time_stamp DESC;"
        val = (user_id,user_id)
        my_cursor.execute(sql,val)
        headers = [x[0] for x in my_cursor.description]
        feed = my_cursor.fetchall()
        json_data=[]
        for result in feed:
            json_data.append(dict(zip(headers,result)))

        for entry in json_data:
            comments = str(entry['comments']).split("|<split>|")
            likes = str(entry['likers']).split("|<cplit>|")
            new_comments = []
            new_likes = []
            for sep_entry in comments:
                sep_comments = sep_entry.split("|<split,>|")
                try:
                    tmp_comment = {"comment": sep_comments[0], "username":sep_comments[1], "user_id":int(sep_comments[2]), "img": sep_comments[3], "time_stamp":sep_comments[4]}
                    new_comments.append(tmp_comment)
                except:
                    None
            entry['comments'] = new_comments
            for sep_entryc in likes:
                sep_like = sep_entryc.split("|<cplit,>|")
                try:
                    tmp_like = {"username": sep_like[0], "user_id":int(sep_like[1])}
                    new_likes.append(tmp_like)
                except:
                    None
            entry['likers'] = new_likes
        return json_data
    #except:
        sock.send((json.dumps({"more": False, "success": False, "error":"Could not get home feed"})).encode("utf-8"))
        return []

    
def get_private_feed(user_id, sock):
    try:        
        my_cursor = mydb.cursor()
        sql = "SELECT title,review_entry.comment AS caption,rating,review_entry.time_stamp,review_entry.img,review_entry.review_id, GROUP_CONCAT(DISTINCT CONCAT(profiles_like.username,'|<cplit,>|',likes.user_id) SEPARATOR '|<cplit>|') as 'likers', GROUP_CONCAT(DISTINCT CONCAT(comments.comment,'|<split,>|',profiles_comment.username,'|<split,>|',comments.user_id,'|<split,>|',profiles_comment.img,'|<split,>|',comments.time_stamp) SEPARATOR '|<split>|') AS 'comments' FROM review_entry LEFT JOIN likes ON likes.review_id = review_entry.review_id LEFT JOIN comments ON review_entry.review_id = comments.review_id LEFT JOIN profiles AS profiles_like ON profiles_like.id = likes.user_id LEFT JOIN profiles as profiles_comment ON profiles_comment.id = comments.user_id WHERE review_entry.user_id = %s GROUP BY review_entry.review_id ORDER BY time_stamp DESC;" 
        val = (user_id,)
        my_cursor.execute(sql,val)
        headers = [x[0] for x in my_cursor.description]
        feed = my_cursor.fetchall()
        json_data=[]
        for result in feed:
            json_data.append(dict(zip(headers,result)))
        for entry in json_data:
            comments = str(entry['comments']).split("|<split>|")
            likes = str(entry['likers']).split("|<cplit>|")
            new_comments = []
            new_likes = []
            for sep_entry in comments:
                sep_comments = sep_entry.split("|<split,>|")
                try:
                    tmp_comment = {"comment": sep_comments[0], "username":sep_comments[1], "user_id":int(sep_comments[2]), "img": sep_comments[3], "time_stamp":sep_comments[4]}
                    new_comments.append(tmp_comment)
                except:
                    None
            entry['comments'] = new_comments
            for sep_entryc in likes:
                sep_like = sep_entryc.split("|<cplit,>|")
                try:
                    tmp_like = {"username": sep_like[0], "user_id":int(sep_like[1])}
                    new_likes.append(tmp_like)
                except:
                    None
            entry['likers'] = new_likes
        return json_data
    except:
        sock.send((json.dumps({"more": False, "success": False, "error":"Could not get private feed"})).encode("utf-8"))
        return []
    
def find_user(username, sock):    

    try:
        my_cursor = mydb.cursor()        
        sql = ("SELECT username, id, img FROM profiles WHERE username = %s")
        val = (username,)
        
        my_cursor.execute(sql, val)
        user_in_db = my_cursor.fetchall() 
    
        if user_in_db == []:
            return (False, None)

        return (True, user_in_db)

    except:
        return False
    
def follow_user(user_to_be_followed_id, sock, key):
    try:
        data = key.data
        my_cursor = mydb.cursor()
        sql = ("INSERT INTO followings (user_id, following_id) VALUES (%s,%s)")
        val = (str(data.user_id), user_to_be_followed_id)
        my_cursor.execute(sql, val)
        mydb.commit()
        return True
    except:
        return False

def unfollow_user(user_to_be_unfollowed_id, sock, key):
    try:
        data = key.data
        my_cursor = mydb.cursor()
        sql = ("DELETE FROM followings WHERE followings.user_id = %s AND followings.following_id = %s")
        val = (str(data.user_id), user_to_be_unfollowed_id)
        my_cursor.execute(sql, val)
        mydb.commit()
        return True
    except:
        return False


def like_review(user_id, review_id, sock):
    try:
        my_cursor = mydb.cursor()
        sql = "INSERT INTO likes (review_id, user_id) VALUES (%s,%s)"
        val = (review_id, user_id)
        my_cursor.execute(sql,val)
        mydb.commit()
        return True
    except:
        return False

def get_profile_pic(user_id):
    my_cursor = mydb.cursor()
    sql = "SELECT img FROM profiles WHERE id = %s"
    val = (user_id,)
    my_cursor.execute(sql,val)
    pic = my_cursor.fetchall()
    if pic:
        return pic[0][0]
    else:
        return ""
    
def unlike_review(user_id, review_id, sock):
    try:
        my_cursor = mydb.cursor()
        sql = "DELETE FROM likes WHERE likes.review_id = %s AND likes.user_id = %s"
        val = (review_id, user_id)
        my_cursor.execute(sql,val)
        mydb.commit()
        return True
    except:
        return False
    
def add_comment(comment, review_id, user_id):
    try:
        my_cursor = mydb.cursor()
        sql = "SELECT followings.user_id FROM followings WHERE followings.following_id = (SELECT review_entry.user_id FROM review_entry WHERE review_entry.review_id = %s)"
        val = (review_id, )
        my_cursor.execute(sql,val)
        result = my_cursor.fetchall()
    except:
        return False
    try:
        sql = "SELECT review_entry.user_id FROM review_entry WHERE review_entry.user_id = (SELECT review_entry.user_id FROM review_entry WHERE review_entry.review_id = %s)"
        val = (review_id, )
        my_cursor.execute(sql,val)
        result2 = my_cursor.fetchall()
        result += result2
    except:
        return False
    try:
        global connected_users
        for user in connected_users:
            if (user.data.user_id,) in result and user.data.user_id != user_id:
                user.fileobj.send(json.dumps({"comment": comment,"review_id": review_id, "user_id": user.data.user_id, "username":user.data.username, "img":get_profile_pic(user.data.user_id), "time_stamp":str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))}).encode())
    
        my_cursor = mydb.cursor()
        sql = "INSERT INTO comments (review_id, comment, user_id) VALUES (%s, %s, %s)"
        val = (review_id, comment, user_id)
        my_cursor.execute(sql,val)
        mydb.commit()
        return True
    except:
        return False


#------------------------------------------------------------------------------------------
#----------------REQUESTS------------------------------------------------------------------
def create_profile_request(profile, sock):
    try:
        my_cursor = mydb.cursor()
        json_obj = json.loads(profile.decode("utf-8")[15:]) # CREATE PROFILE {"username": "adam", "email": adam@mail.se, "password": "adam123", "img":"url till img"}

        username = json_obj["username"]
        email = json_obj["email"]
        
        if(not valid_account(username, email)):
            msg_to_send = json.dumps({"success": False, "error": "Username or email already taken"})
            sock.send((msg_to_send).encode())
            return
        
        else:
            sql = "INSERT INTO profiles (username, email, password, img) VALUES (%s, %s, %s, %s)"
            val = (json_obj["username"], json_obj["email"], hash_password(json_obj["password"]), json_obj["img"])
            my_cursor.execute(sql, val)
            mydb.commit()
            msg_to_send = json.dumps({"success": True, "error": ""})
            sock.send((msg_to_send).encode())

    except:
         sock.send((json.dumps({"success":False, "error":"Invalid arguments"})).encode())

def add_review_request(review, sock, key):
    try:
        print(review)
        user_id = key.data.user_id
        username = key.data.username
        
        my_cursor = mydb.cursor();

        json_obj = json.loads(review.decode("utf-8")[7:]) # för att lägga till i databasen skriv ENTRY {"id": "imdb_id", "title": "title", "comment": "comment", "rating": 5} i telnet
        sql = "INSERT INTO review_entry (IMDB_id, title, comment, rating, username, user_id, img) VALUES (%s, %s, %s, %s, %s, %s, %s)"  
        val = (json_obj["IMDB_id"], json_obj["title"], json_obj["comment"], float(json_obj["rating"]), username, user_id, json_obj["img"])
        
        my_cursor.execute(sql, val)
        mydb.commit()
        msg_to_send = json.dumps({"success": True, "error": ""})
        sock.send((msg_to_send).encode())

    except BaseException as e:
        msg_to_send = json.dumps({"success": False, "error": "Invalid arguments"})
        sock.send((msg_to_send).encode())
        print(str(e))

def login_request(user, sock, key):
    try:
        my_cursor = mydb.cursor()
        json_obj = json.loads(user.decode("utf-8")[5:])  # LOGIN {"username": "adam", "password": "myPassword"}

        username = json_obj["username"]
        password = json_obj["password"]

        if(valid_login(username, password)):
            msg_to_send = json.dumps({"success": True, "error": ""})
            sock.send((msg_to_send).encode())
            key.data.username = username
            key.data.user_id = get_user_id(username)
            key.data.logged_in = True
            global connected_users
            connected_users.append(key)
        else:
            msg_to_send = json.dumps({"success": False, "error": "Invalid username or password"})
            sock.send((msg_to_send).encode())

    except:
        msg_to_send = json.dumps({"success": False, "error": "Invalid arguments"})
        sock.send((msg_to_send).encode())

def movie_request(movie_input, sock):
    try:
        json_obj = json.loads(movie_input.decode("utf-8")[11:])
        title = json_obj["title"]
        movie_output = find_movie(title)
        if (not movie_output):
            sent = sock.send(json.dumps({"success": False, "movies": "", "error": "No such movie"}).encode())
        else:
            json_movies = {"success": True, "movies": movie_output, "error": ""}
            sent = sock.send((json.dumps(json_movies)).encode())  # Should be ready to write
    except:
        sock.send((json.dumps({"success":False, "movies": "", "error": "Invalid arguments"})).encode())
        


def find_request(username, sock):
    json_obj = json.loads(username.decode("utf-8")[10:])
    user = find_user(json_obj["username"], sock)
    print(user)
    if user[0]:
        msg_to_send = json.dumps({"success": True, "error": "", "username": user[1][0][0], "user_id": user[1][0][1], "img":user[1][0][2]})
        sock.send((msg_to_send).encode())
    else:
        sock.send((json.dumps({"success":False, "error":"Could not find user"})).encode())

def follow_request(request, sock, key):
     try:
        my_cursor = mydb.cursor()
        json_obj = json.loads(request.decode("utf-8")[7:])
        # FOLLOW {"follow_user_id": "3"}
        user_to_be_followed = json_obj["user_id"]

        if (follow_user(user_to_be_followed, sock, key)):
            sock.send(json.dumps({"success":True, "error":"None"}).encode())
        else:
            sock.send(json.dumps({"success":False, "error":"Invalid arguments"}).encode())
        
     except:
         sock.send(json.dumps({"success": False, "error":"Invalid arguments"}).encode())

def unfollow_request(request, sock, key):
     try:
        my_cursor = mydb.cursor()
        json_obj = json.loads(request.decode("utf-8")[9:])
        # UNFOLLOW {"unfollow_user_id": "1"}
        # kanske ändra user_to_be_unfollowed till target bara?
        # Vi vill lägga till säkerhet här, någon check så att kontona faktiskt finns
        # Kanske inte behövs, sql kommer inte göra något om den inte finns.
        user_to_be_unfollowed = json_obj["user_id"]
        if (unfollow_user(user_to_be_unfollowed, sock, key)):
            sock.send(json.dumps({"success":True, "error":"None"}).encode())
        else:
            sock.send(json.dumps({"success":False, "error":"Invalid arguments"}).encode())
        
     except:
         sock.send(json.dumps({"success": False, "error":"Invalid arguments"}).encode())

def get_followings_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode()[11:])
        username = json_obj["username"]
        user_id = get_user_id(username)

        followings = get_followings(user_id)
    
        sock.send((json.dumps({"success": True, "error": "", "followings": followings})).encode("utf-8"))

    except:
        sock.send((json.dumps({"success": False, "error": "Could not get this users followings"})).encode("utf-8"))


def get_followers_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode()[10:])
        username = json_obj["username"]
        user_id = get_user_id(username)

        followers = get_followers(user_id)
    
        sock.send((json.dumps({"success": True, "error": "", "followers": followers})).encode("utf-8"))

    except:
        sock.send((json.dumps({"success": False, "error": "Could not get this users followers"})).encode("utf-8"))
    


def get_my_followings_request(request, sock, key):
    try:
        user_id = key.data.user_id
        my_followings = get_followings(user_id)

        sock.send((json.dumps({"success": True, "error": "", "followings": my_followings})).encode("utf-8"))
    except:
           sock.send((json.dumps({"success": False, "error": "Could not get my followings"})).encode("utf-8"))

def get_my_followers_request(request, sock, key):
    try:
        user_id = key.data.user_id
        my_followers = get_followers(user_id)

        sock.send((json.dumps({"success": True, "error": "", "followers": my_followers})).encode("utf-8"))
    except:
           sock.send((json.dumps({"success": False, "error": "Could not get my followers"})).encode("utf-8"))
    


def like_review_request(request, sock, key):
    json_obj = json.loads(request.decode()[5:])
    review_id = json_obj["review_id"]
    if (like_review(key.data.user_id, review_id, sock)):
        sock.send(json.dumps({"success":True, "error":"None"}).encode())
    else:
        sock.send(json.dumps({"success":False, "error":"Invalid arguments"}).encode())
    

def unlike_review_request(request, sock, key):
    json_obj = json.loads(request.decode()[7:])
    review_id = json_obj["review_id"]
    if (unlike_review(key.data.user_id, review_id, sock)):
        msg_to_send = json.dumps({"success": True, "error": ""})
        sock.send(msg_to_send.encode())
    else:
        sock.send(json.dumps({"success":False, "error":"Invalid arguments"}).encode())

def home_feed_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode()[10:])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    user_id = key.data.user_id
    try:
        feed_index = int(json_obj["index"])
        refresh = bool(json_obj["refresh"])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    if refresh:
        feed = get_home_feed(user_id, sock)
        key.data.home_feed = feed
    feed = key.data.home_feed
    if feed_index*10 >= len(feed):
        try:
            sock.send((json.dumps({"feed":feed[(feed_index-1)*10:], "more":False, "error":""},default=str)).encode('utf-8'))
        except:
            sock.send((json.dumps({'feed':[], 'more':False, 'error':"Index out of bounds"},default=str)).encode('utf-8'))
    else:
        sock.send((json.dumps({'feed':feed[(feed_index-1)*10:feed_index*10], 'more':True, 'error':""}, default=str)).encode('utf-8'))
    

def private_feed_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode()[13:])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    user_id = key.data.user_id
    try:
        feed_index = int(json_obj["index"])
        refresh = bool(json_obj["refresh"])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    if refresh:
        feed = get_private_feed(user_id, sock)
        key.data.private_feed = feed
    feed = key.data.private_feed
    if feed_index*10 >= len(feed):
        try:
            sock.send((json.dumps({"feed":feed[(feed_index-1)*10:], "more":False, "error":""},default=str)).encode('utf-8'))
        except:
            sock.send((json.dumps({'feed':[], 'more':False, 'error':"Index out of bounds"},default=str)).encode('utf-8'))
    else:
        sock.send((json.dumps({'feed':feed[(feed_index-1)*10:feed_index*10], 'more':True, 'error':""}, default=str)).encode('utf-8'))

def specific_feed_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode("utf-8")[14:])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    username = json_obj["username"]
    user_id = get_user_id(username)
    try:
        feed_index = int(json_obj["index"])
        refresh = bool(json_obj["refresh"])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong argument"}).encode())
        return
    if refresh:
        feed = get_private_feed(user_id, sock)
        key.data.private_feed = feed
    feed = key.data.private_feed
    if feed_index*10 > len(feed):
        try:
            sock.send((json.dumps({"feed":feed[(feed_index-1)*10:], "more":False, "error":""},default=str)).encode('utf-8'))
        except:
            sock.send((json.dumps({'feed':[], 'more':False, 'error':"Index out of bounds"},default=str)).encode('utf-8'))
    else:
        sock.send((json.dumps({'feed':feed[(feed_index-1)*10:feed_index*10], 'more':True, 'error':""}, default=str)).encode('utf-8'))


def comment_request(request, sock, key):
    try:
        json_obj = json.loads(request.decode("utf-8")[8:])
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong arguments"}).encode())
        return
    try:
        comment = json_obj["comment"]
        review_id = json_obj["review_id"]
    except:
        sock.send(json.dumps({"success":False, "error":"Wrong arguments"}).encode())
        return
    if add_comment(comment, review_id, key.data.user_id):
        sock.send(json.dumps({"success":True, "error":""}).encode())
    else:
        sock.send(json.dumps({"success":False, "error":"Could not add comment"}).encode())
        

def update_notification_time_request(request, sock, key):
    user_id = key.data.user_id
    try:
        my_cursor = mydb.cursor()
        sql = "UPDATE profiles SET notification_timestamp = now() WHERE user_id = %s;"
        val = user_id
        my_cursor.execute(sql, val)
        mydb.commit()
        msg_to_send = json.dumps({"success": True, "error": ""})
        sock.send((msg_to_send).encode())
    except:
        msg_to_send = json.dumps({"success": False, "error": "Did not manage to update notification timestamp"})
        sock.send((msg_to_send).encode())

def get_notifications_request(request, sock, key):
    try:
        new_likes = get_new_likes()
        new_comments = get_new_comments()
        new_followers = get_new_followers()
        notifications = {"success": True, "likes": new_likes, "comments": new_comments, "followers": new_followers, "error": ""}
        sock.send((json.dumps(notifications)).encode())
    except:
        sock.send((json.dumps({"success": False, "error": "Could not get notifications"})).encode())
    
    
#------------------------------------------------------------------------------------------
#-----------------UPLOAD-------------------------------------------------------------------
def upload_pic(picture_data, sock, key):
    try:
        json_obj = json.loads(picture_data[11:].decode("utf-8"))
        global valid_formats
        if not str(json_obj["size"]).isdigit():
            key.data.uploading = False
            key.data.outb = b""
            msg_to_send = json.dumps({"success": False, "error": "Filesize not a valid number"})
            sock.send(msg_to_send.encode())
            return 
    
        key.data.pic_size = int(json_obj["size"])
    
        if json_obj["type"] in valid_formats:        
            key.data.pic_type = json_obj["type"]
        else:
            key.data.uploading = False
            key.data.outb = b""
            msg_to_send = json.dumps({"success": False, "error": "Invalid file format"})
            sock.send(msg_to_send.encode())
            return
        key.data.uploading = True
    except:
       key.data.outb = b""
       key.data.uploading = False
       msg_to_send = json.dumps({"success": False, "error": "Invalid query"})
       sock.send(msg_to_send.encode())

def add_picture_data(sock, key):
    data = key.data
    data.pic_data += data.outb
    data.pic_size -= len(data.outb)
    global img_counter
    if data.pic_size <= 0:
        f = open("img/image"+str(img_counter) + "." + data.pic_type, 'wb')
        try:
            f.write(base64.b64decode(data.pic_data))
        except:
            pic = data.pic_data + b'=' * (-len(data.pic_data) % 4)   
            f.write(base64.b64decode(pic))
        f.close
        url = "http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/"+"image"+str(img_counter)+"."+data.pic_type
        msg_to_send = json.dumps({"success": True, "error": "", "url": url})
        sock.send(msg_to_send.encode())
        img_counter += 1
        data.uploading = False
        data.pic_data = b""
        data.pic_size = 0
        data.pic_type = ""
        data.outb = b""
        f = open("img_count.txt",'wb')
        f.write(str(img_counter).encode())
        f.close()
        
#--------------------------------------------------------------------------------------

def handle_request(request, sock, key):
    if key.data.uploading and key.data.logged_in: # Måste vara först så att vi inte försöker decoda bilddata, det kan krasha. 
        add_picture_data(sock,key)
        return True

    if request.decode('utf-8')[0:6] == "LOGIN ":
        login_request(request, sock, key)
        return True

    if request.decode('utf-8')[0:15] == "CREATE PROFILE ":
        create_profile_request(request, sock)
        return True

    if key.data.logged_in:
    
        if request.decode('utf-8')[0:7] == "REVIEW ":
            add_review_request(request, sock, key)
            return True
    
        if request.decode('utf-8')[0:11] == "FIND MOVIE ":
            movie_request(request, sock)
            return True

        if request.decode('utf-8')[0:7] == "FOLLOW ":
            follow_request(request, sock, key)
            return True

        if request.decode('utf-8')[0:9] == "UNFOLLOW ":
            unfollow_request(request, sock, key)
            return True
    
        if request.decode('utf-8')[0:11] == "UPLOAD PIC ":
            upload_pic(request, sock, key)
            return True

        if request.decode('utf-8')[0:8] == "COMMENT ":
            comment_request(request, sock, key)
            return True
    
        if request.decode('utf-8')[0:10] == "FIND USER ":
            find_request(request, sock)
            return True

        if request.decode('utf-8')[0:5] == "LIKE ":
            like_review_request(request, sock, key)
            return True

        if request.decode('utf-8')[0:7] == "UNLIKE ":
            unlike_review_request(request, sock, key)
            return True

        if request.decode()[0:11] == "FOLLOWINGS ":
            get_followings_request(request, sock, key)
            return True

        if request.decode()[0:10] == "FOLLOWERS ":
            get_followers_request(request, sock, key)
            return True
        
        if request.decode()[0:14] == "MY FOLLOWINGS ":
            get_my_followings_request(request, sock, key)
            return True

        if request.decode()[0:13] == "MY FOLLOWERS ":
            get_my_followers_request(request, sock, key)
            return True
        
        if request.decode('utf-8')[0:10] == "HOME FEED ":
            home_feed_request(request, sock, key)
            return True
        
        if request.decode()[0:13] == "PRIVATE FEED ":
            private_feed_request(request, sock, key)
            return True
        
        if request.decode()[0:14] == "SPECIFIC FEED ":
            specific_feed_request(request, sock, key)
            return True

        if request.decode()[0:25] == "UPDATE NOTIFICATION TIME ":
            update_notification_time_request(request, sock, key)
            return True

        if request.decode()[0:18] == "GET NOTIFICATIONS ":
            get_notifications_request(request, sock, key)
            return True

        
        
    return False
     
def service_connection(key, mask):
    sock = key.fileobj
    data = key.data
    if mask & selectors.EVENT_READ:
        if data.uploading:
            try:
                recv_data = sock.recv(data.pic_size)
            except:
                sel.unregister(sock)
                sock.close()
                return
        else:
            try:
                recv_data = sock.recv(1024)  # Should be ready to read
            except:
                sel.unregister(sock)
                sock.close()
                return
        if recv_data:
            data.outb += recv_data
            if handle_request(data.outb, sock, key):
                data.outb = "".encode()
        else:
            print("closing connection to", data.addr)
            sel.unregister(sock)
            sock.close()
    if mask & selectors.EVENT_WRITE:
        if data.outb:
            ##print(data.outb)
            sent = sock.send((json.dumps({"success":False, "error":"Invalid command"})).encode())
            data.outb = data.outb[sent:]

host = "127.0.0.1"
port = 8888
lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
lsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
lsock.bind((host, port))
lsock.listen()
valid_formats = ["png", "jpeg", "jpg", "gif", "heic", "txt", "heif"]
connected_users = []
print("listening on", (host, port))
lsock.setblocking(False)
sel.register(lsock, selectors.EVENT_READ, data=None)
f = open("img_count.txt",'rb')
img_counter = int(f.read(10))
f.close()
try:
    while True:
        events = sel.select(timeout=None)
        for key, mask in events:
            if key.data is None:
                accept_wrapper(key.fileobj)
            else:
                service_connection(key, mask)
except KeyboardInterrupt:
    print("caught keyboard interrupt, exiting")
finally:

    lsock.shutdown(2)
    lsock.close()
    sel.close()
