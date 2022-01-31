import sys
import socket
import unittest
import os
import json
import mysql.connector
import time
import base64

mydb = mysql.connector.connect(
    host="ec2-13-49-72-142.eu-north-1.compute.amazonaws.com",
    user="root",
    passwd="Bossy56!",
    database="bossy"
)

def test_cleanup():
    my_cursor = mydb.cursor()
    sql = "DELETE FROM likes WHERE review_id = 19"
    my_cursor.execute(sql)
    mydb.commit()

server_addr = ("127.0.0.1",8888)        
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
while sock.connect_ex(server_addr):
    i=0 #Stall until connected
sock.send(b'LOGIN {"username":"test1","password":"test"}')
sock.recv(4096)
class test(unittest.TestCase):

    
    def test_find_movie(self):
        sock.send('FIND MOVIE {"title": "Breaking bad"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["success"], True)
        
    def test_fail_find_movie(self):
        sock.send('FIND MOVIE {"title": "aaaaa"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "No such movie")

    def test_find_movie_weird_input1(self):
        sock.send('FIND MOVIE {"title": "\n"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments")       

    def test_taken_account_name(self):
        sock.send('CREATE PROFILE {"username":"test1","email":"testing@email.com","password":"test", "img":"test"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Username or email already taken")
        
    def test_taken_account_email(self):
        sock.send('CREATE PROFILE {"username": "test2", "email": "test@mail.se", "password":"test", "img":"test"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Username or email already taken")

    def test_invalid_command(self):
        sock.send('DO SOMETHING test'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid command", 'Should be "Invalid command"')
        
    def test_create_profile_no_args(self):
        sock.send('CREATE PROFILE '.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments", 'Should be "Invalid arguments" but got '+ ans["error"])

    def test_review_no_args(self):
        sock.send('REVIEW '.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments")

    def test_invalid_login(self):
        sock.send('LOGIN {"username": "nonexisting_username", "password": "123"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid username or password")

    def test_valid_login(self):
        sock.send('LOGIN {"username": "test1", "password": "test"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["success"], True)

    def test_find_movie_no_args(self):
        sock.send('FIND MOVIE '.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments")

    def test_create_profile_wrong_args(self):
        sock.send('CREATE PROFILE {"test":"this is wrong"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments", 'Should be "Invalid arguments"')

    def test_review_wrong_args(self):
        sock.send('REVIEW {"test":"this is wrong"}'.encode())
        ans = json.loads(sock.recv(4096).decode("utf-8"))
        self.assertEqual(ans["error"], "Invalid arguments")

    def test_send_img_jpeg(self):
        f = open('img/test1.jpeg','rb')
        size = os.stat("img/test1.jpeg").st_size
        l = f.read(size)
        size = len(base64.b64encode(l))
        sock.send(('UPLOAD PIC '+ '{"size":' + str(size) + ',"type":"jpeg"}').encode())        
        sock.send(base64.b64encode(l))
        f.close()
        ans = sock.recv(4096).decode()        
        self.assertEqual("http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/" in ans and "jpeg" in ans, True, "Got " + ans + "but expected http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/imageXX.jpeg")

    def test_send_img_png(self):
        f = open('img/test2.png','rb')
        size = os.stat("img/test2.png").st_size
        l = f.read(size)
        size = len(base64.b64encode(l))
        sock.send(('UPLOAD PIC '+ '{"size":' + str(size) + ',"type": "png"}').encode())
        sock.send(base64.b64encode(l))
        f.close()
        ans = sock.recv(4096).decode()        
        self.assertEqual("http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/" in ans and "png" in ans, True, "Got " + ans + "but expected http://ec2-13-49-72-142.eu-north-1.compute.amazonaws.com/imageXX.png")

    def test_send_img_wrong_format(self):
        sock.send(('UPLOAD PIC '+ '{"size":' + "20" + ',"type": "pngtest"}').encode())        
        ans = json.loads(sock.recv(4096).decode())
        self.assertEqual(ans["error"], "Invalid file format")
        
    def test_send_img_negative_size(self):
        sock.send(('UPLOAD PIC '+ '{"size":' + "-100" + ',"type":"png"}').encode())        
        ans = json.loads(sock.recv(4096).decode())
        self.assertEqual(ans["error"], "Filesize not a valid number")
        
    def test_send_img_size_not_a_number(self):
        sock.send(('UPLOAD PIC '+ '{"size":' + '"te5t"' + ',"type": "png"}').encode())        
        ans = json.loads(sock.recv(4096).decode())
        self.assertEqual(ans["error"], "Filesize not a valid number")

    def test_like_review(self):
        sock.send(('LIKE {"review_id":19}').encode())        
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True)

    def test_unlike_review(self):
        sock.send(('UNLIKE {"review_id":19}').encode())        
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True, "Got " + str(json_obj["success"]) + ' but expected "True"')

    def test_follow_user(self):
        sock.send(('FOLLOW {"user_id":25}').encode())        
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True)

        
    def test_unfollow_user(self):
        sock.send(('UNFOLLOW {"user_id":25}').encode())        
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True)


    def test_get_my_followings(self):
        sock.send(('MY FOLLOWINGS ').encode())
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True)

    def test_get_followings(self):
        sock.send(('FOLLOWINGS {"username": "test1"}').encode())
        ans = sock.recv(4096).decode()
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], True)
        
    def test_get_private_feed(self):
        sock.send(('PRIVATE FEED ' +  json.dumps({"index":1, "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["more"], False)

    def test_get_private_feed_no_more_to_get(self):
        sock.send(('PRIVATE FEED ' +  json.dumps({"index":3, "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["feed"], [])

    def test_get_private_feed_wrong_arg(self):
        sock.send(('PRIVATE FEED ' +  json.dumps({"index":"a", "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], False)

    def test_get_private_feed_refresh(self):
        sock.send(('PRIVATE FEED ' +  json.dumps({"index":1, "refresh":True})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["more"], False)

    def test_get_private_feed_invalid_index(self):
        sock.send(('PRIVATE FEED ' +  json.dumps({"index":0, "refresh":True})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["feed"], [])
        
    def test_get_home_feed(self):
        sock.send(('HOME FEED ' + json.dumps({"index":1, "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["more"], False)

    def test_get_home_feed_no_more_to_get(self):
        sock.send(('HOME FEED ' +  json.dumps({"index":3, "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["feed"], [])
    
    def test_get_home_feed_wrong_arg(self):
        sock.send(('HOME FEED ' +  json.dumps({"index":"a", "refresh":False})).encode())
        ans = sock.recv(4096)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["success"], False)

    def test_get_home_feed_refresh(self):
        sock.send(('HOME FEED ' +  json.dumps({"index":1, "refresh":True})).encode())
        ans = sock.recv(8000)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["more"], True)

    def test_get_home_feed_invalid_index(self):
        sock.send(('HOME FEED ' +  json.dumps({"index":0, "refresh":True})).encode())
        ans = sock.recv(8000)
        json_obj = json.loads(ans)
        self.assertEqual(json_obj["feed"], [])
        
if __name__ == '__main__':
    unittest.main()
