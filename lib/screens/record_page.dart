import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'timer_page.dart';

class Record extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('history', style: TextStyle(fontSize: 30.0, fontFamily: "Bebas Neue"))),
      body: new Container(
        child: new RecordList()
      ),
    );
  }

}

class RecordList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection(user_id).orderBy("created_at", descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting: return Container(alignment: Alignment.center, child: CircularProgressIndicator());
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
		initializeDateFormatting("ja_JP");
		DateTime datetime = DateTime.parse(document['created_at'].toDate().toString());
		var formatter = new DateFormat('yyyy/MM/dd(E) HH:mm', "ja_JP");
                var text_date = formatter.format(datetime); // DateからString
                int milis = document['time'];
		int hour = (milis / 3600000).truncate();
		int minute = (milis / 60000 - hour * 60).truncate();
		int second = (milis / 1000 - hour * 3600 - minute * 60).truncate();
		String hourStr = hour.toString().padLeft(2, '0');
		String minuteStr = minute.toString().padLeft(2, '0');
		String secondStr = second.toString().padLeft(2, '0');

                return new Card(
		  child: ListTile(
                    title: new Text('${document['distance'].toStringAsFixed(0)}m', style: TextStyle(fontSize: 20.0, fontFamily: "Bebas Neue")),
                    subtitle: new Text('$hourStr:$minuteStr:$secondStr'),
                    leading: new Text(text_date, style: TextStyle(fontSize: 20.0, fontFamily: "Bebas Neue")),
		  ),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
