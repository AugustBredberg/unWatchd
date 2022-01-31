import 'package:flutter/material.dart';
import 'package:un_watchd/screens/home/feed2.dart';
import 'package:un_watchd/screens/home/profile.dart';
import 'package:un_watchd/services/auth.dart' as auth;
import 'package:un_watchd/screens/home/search.dart';
import 'package:un_watchd/screens/home/notifications.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => new Container(
        color: Colors.yellow,
        child: WillPopScope(
          onWillPop: () async => false,
          child: DefaultTabController(
            length: 4,
            child: new Scaffold(
              body: TabBarView(
                children: [
                  TabContent(new Feed2()),
                  TabContent(new Search()),
                  TabContent(new Notifications()),
                  TabContent(new Profile(auth.usernameLOGGEDIN, 0, 0, 0, 0)),
                ],
              ),
              bottomNavigationBar: new TabBar(
                tabs: [
                  Tab(icon: new Icon(Icons.home)),
                  Tab(
                    icon: new Icon(Icons.search),
                  ),
                  Tab(
                    icon: new Icon(Icons.notifications),
                  ),
                  Tab(
                    icon: new Icon(Icons.perm_identity),
                  )
                ],
                labelColor: Colors.yellow,
                unselectedLabelColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.all(5.0),
                indicatorColor: Colors.redAccent,
              ),
              floatingActionButton: Align(
                child: Container(
                  height: 30,
                  width: 30,
                  child: FloatingActionButton(
                      child: Icon(
                        Icons.add_circle_outline,
                        size: 30,
                        color: Colors.blue,
                      ),
                      backgroundColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/post');
                      }),
                ),
                alignment: Alignment(0, 0.92),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );
}

class TabContent extends StatefulWidget {
  final Widget content;
  TabContent(this.content);

  @override
  _TabContentState createState() => _TabContentState();
}

class _TabContentState extends State<TabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    print('init ${widget.content}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // print('build ${widget.content}');

    return widget.content;
  }

  @override
  bool get wantKeepAlive => false;
}
