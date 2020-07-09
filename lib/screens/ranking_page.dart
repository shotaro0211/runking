import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'timer_page.dart';

class Ranking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('today ranking', style: TextStyle(fontSize: 30.0, fontFamily: "Bebas Neue"))),
      body: new Container(
        child: new RankingList()
      ),
    );
  }

}

class RankingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting("ja_JP");
    DateTime datetime = DateTime.now();
    var formatter = new DateFormat('yyyyMMdd', "ja_JP");
    String text_date = formatter.format(datetime); // DateからString

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(text_date).orderBy('distance', descending: true).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
	int i = 0;

        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
		case ConnectionState.waiting: return Container(alignment: Alignment.center, child: CircularProgressIndicator());
          default:
            return new ListView(
              children: snapshot.data.documents.map((DocumentSnapshot document) {
		i += 1;
                int milis = document['time'];
		int hour = (milis / 3600000).truncate();
		int minute = (milis / 60000 - hour * 60).truncate();
		int second = (milis / 1000 - hour * 3600 - minute * 60).truncate();
		String hourStr = hour.toString().padLeft(2, '0');
		String minuteStr = minute.toString().padLeft(2, '0');
		String secondStr = second.toString().padLeft(2, '0');
		String my_ranking = idBool(document['id']);

                return new Card(
		  child: ListTile(
                    title: new Text('${document['name']}', style: TextStyle(fontSize: 20.0, fontFamily: "Bebas Neue")),
                    subtitle: new Text('${document['distance'].toStringAsFixed(0)}m  $hourStr:$minuteStr:$secondStr'),
                    leading: new Text('No.${i}', style: TextStyle(fontSize: 30.0, fontFamily: "Bebas Neue")),
                    trailing: new Text(my_ranking, style: TextStyle(fontSize: 20.0, fontFamily: "Bebas Neue")),
		  ),
                );
              }).toList(),
            );
        }
      },
    );
  }

  String idBool(String id){
    String text = '';
    if (user_id == id) {
      text = 'YOU';
    }
    return text;
  }
	    
      
}
