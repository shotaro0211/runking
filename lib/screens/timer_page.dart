import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:runking/components/location_text.dart';
  
String user_id;
String user_name = '名無し';
SharedPreferences prefs;

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;
  final int hours;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
    this.hours,
  });
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners = <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(fontSize: 90.0, fontFamily: "Bebas Neue");
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class Home extends StatelessWidget {
  Home({Key key}) : super(key: key);
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("RUNKING", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40, fontFamily: "Bebas Neue")),
	actions: <Widget>[
            // action button
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
		showDialog(
		  context: context,
		  barrierDismissible: false, // dialog is dismissible with a tap on the barrier
		  builder: (BuildContext context) => new AlertDialog(
	            title: new Text("new name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "Bebas Neue")),
		    content: TextField(
		      controller: myController,
	              autofocus: true,
                      decoration: InputDecoration(hintText: user_name),
                    ),
		    // ボタンの配置
		    actions: <Widget>[
		      new FlatButton(
		        child: const Text('cancel'),
		        onPressed: () {
			Navigator.pop(context);
		      }),
		      new FlatButton(
			child: const Text('change name'),
		        onPressed: () {
			  prefs.setString('user_name', myController.text);
			  user_name = myController.text;
			  Navigator.pop(context);
		        }
		      )
	            ],
		  ),
		);
              },
            ),
        ],
      ),
      body: new Container(
        child: new TimerPage()
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  TimerPage({Key key}) : super(key: key);

  TimerPageState createState() => new TimerPageState();
}

class TimerPageState extends State<TimerPage> {
  Dependencies dependencies = new Dependencies();

  //ボタンを押した後の処理
  void leftButtonPressed() {
    setState(() {
      if (!dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.reset();
	total_distance = 0;
      }
    });
  }

  void leftButtonLongPress() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
	initializeDateFormatting("ja_JP");
	DateTime datetime = DateTime.now();
	var formatter = new DateFormat('yyyyMMdd', "ja_JP");
        String text_date = formatter.format(datetime); // DateからString

	Firestore.instance.collection(user_id).document().setData({'id': user_id, 'name': user_name, 'distance': total_distance, 'time': dependencies.stopwatch.elapsedMilliseconds, 'created_at': DateTime.now()});
	Firestore.instance.collection(text_date).document().setData({'id': user_id, 'name': user_name, 'distance': total_distance, 'time': dependencies.stopwatch.elapsedMilliseconds, 'created_at': DateTime.now()});
        dependencies.stopwatch.stop();
        dependencies.stopwatch.reset();
	total_distance = 0;
      }
    });
  }

  void rightButtonPressed() {
    setState(() {
      if (dependencies.stopwatch.isRunning) {
        dependencies.stopwatch.stop();
      } else {
	if (dependencies.stopwatch.elapsedMilliseconds == 0) {
	  total_distance = 0;
	}
        dependencies.stopwatch.start();
      }
    });
  }

  //右ボタン作成の処理
  Widget buildFloatingRightButton(String text, VoidCallback callback) {
    TextStyle roundTextStyle = const TextStyle(fontSize: 30.0, color: Colors.black,fontFamily: "Bebas Neue");
    Container myFabButton = Container(
      width: 150.0,
      height: 150.0,
      child: new RawMaterialButton(
        shape: new CircleBorder(),
        elevation: 0.0,
        child: new Text(text, style: roundTextStyle),
        onPressed: callback,
      ),
    );
    return myFabButton;
  }

  //左ボタン作成の処理
  Widget buildFloatingLeftButton(String text, VoidCallback callback1, VoidCallback callback2) {
    TextStyle roundTextStyle = const TextStyle(fontSize: 30.0, color: Colors.black,fontFamily: "Bebas Neue");
    Container myFabButton = Container(
      width: 150.0,
      height: 150.0,
      child: new RawMaterialButton(
        shape: new CircleBorder(),
        elevation: 0.0,
        child: new Text(text, style: roundTextStyle),
        onPressed: callback1,
	onLongPress: callback2, 
      ),
    );
    return myFabButton;
  }
  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Expanded(
          child: new SizedBox(height: 200,),
        ),
        new Expanded(
          flex: 1,
          child: new TimerText(dependencies: dependencies),
        ),
	new Expanded(
          flex: 0,
	  child: new LocationText(),
	),
        new Expanded(
          flex: 3,
          child: new Padding(
            padding: const EdgeInsets.symmetric(vertical: 50.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildFloatingLeftButton(dependencies.stopwatch.isRunning ? "record" : "reset", leftButtonPressed, leftButtonLongPress),
                buildFloatingRightButton(dependencies.stopwatch.isRunning ? "stop" : "start", rightButtonPressed),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

//タイマー表示部分
class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() => new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate), callback);
    connectData();
    super.initState();
  }

  //ローカルデータ取得
  void connectData() async {
    prefs = await SharedPreferences.getInstance();
    String local_name = prefs.getString('user_name') ?? '';
    if (local_name != '') {
        user_name = local_name;
    } 
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    user_id = iosDeviceInfo.identifierForVendor;
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final int hours = (minutes / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
        hours: hours,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          new RepaintBoundary(
            child: new SizedBox(
              height: 100.0,
              child: new HoursAndMinutes(dependencies: dependencies),
            ),
          ),
          new RepaintBoundary(
            child: new SizedBox(
              height: 100.0,
              child: new Seconds(dependencies: dependencies),
            ),
          ),
      ],
    );
  }
}

//時・分
class HoursAndMinutes extends StatefulWidget {
  HoursAndMinutes({this.dependencies});
  final Dependencies dependencies;

  HoursAndMinutesState createState() => new HoursAndMinutesState(dependencies: dependencies);
}

class HoursAndMinutesState extends State<HoursAndMinutes> {
  HoursAndMinutesState({this.dependencies});
  final Dependencies dependencies;

  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.hours != hours || elapsed.minutes != minutes) {
      setState(() {
        hours = elapsed.hours;
        minutes = elapsed.minutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    return new Text('$hoursStr:$minutesStr:', style: dependencies.textStyle);
  }
}

//秒
class Seconds extends StatefulWidget {
  Seconds({this.dependencies});
  final Dependencies dependencies;

  SecondsState createState() => new SecondsState(dependencies: dependencies);
}

class SecondsState extends State<Seconds> {
  SecondsState({this.dependencies});
  final Dependencies dependencies;

  int seconds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.seconds != seconds) {
      setState(() {
        seconds = elapsed.seconds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return new Text(secondsStr, style: dependencies.textStyle);
  }
}
