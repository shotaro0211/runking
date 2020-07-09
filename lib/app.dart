import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'screens/timer_page.dart';
import 'screens/ranking_page.dart';
import 'screens/record_page.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  List<Widget> _pages = [
    Home(),
    Ranking(),
    Record(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: _buildMy_appTabBar(),
      tabBuilder: (BuildContext context, int index) {
	return new CupertinoTabView(
	  builder: (BuildContext context) {
	    return CupertinoPageScaffold(
	      child: _pages[index],
	    );
	  },
	);
      },
    );
  }
}

CupertinoTabBar _buildMy_appTabBar() {
  return CupertinoTabBar(
    backgroundColor: Colors.black,
    activeColor: Colors.orange,
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: new Icon(Icons.directions_run, size: 28.0),
	title: Text('', style: TextStyle(fontSize: 0.0)),
      ),
      BottomNavigationBarItem(
	icon: Icon(FontAwesomeIcons.crown, size:24.0),
	title: Text('', style: TextStyle(fontSize: 0.0)),
      ),
      BottomNavigationBarItem(
        icon: Icon(FontAwesomeIcons.history, size:24.0),
	title: Text('', style: TextStyle(fontSize: 0.0)),
      ),
    ],
  );
}
