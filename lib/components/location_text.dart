import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:runking/screens/timer_page.dart';

class LocationText extends StatefulWidget{
  @override
  LocationTextState createState() => LocationTextState();
}

// Distance
double total_distance = 0; // Geolocator

class LocationTextState extends State<LocationText> {
  // Stream
  var geolocator = Geolocator();
  var locationOptions = LocationOptions(accuracy: LocationAccuracy.best, distanceFilter: 100);

  @override
  void initState() {
    super.initState();
    _getLocation(context);
  }

  @override
  void dispose() {
    geolocator.getPositionStream(null).listen(null);
    super.dispose();
  }

  Future<void> _getLocation(context) async {
    Position _currentPosition = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best); // ここで精度を「best」に指定している
    geolocator.getPositionStream(locationOptions).listen((Position stream_position) {
      //print(stream_position == null ? 'Unknown' : stream_position.latitude.toString() + ', ' + stream_position.longitude.toString());
      Position _pastPosition = _currentPosition;
      _currentPosition = stream_position;
      _updatePosition(_currentPosition, _pastPosition);
    });
  }
  Future<void> _updatePosition(Position _currentPosition, Position _pastPosition) async {
    double distanceInMeters = await Geolocator().distanceBetween(_pastPosition.latitude, _pastPosition.longitude, _currentPosition.latitude, _currentPosition.longitude);
    setState(() {
      total_distance += distanceInMeters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GeolocationStatus>(
      future: Geolocator().checkGeolocationPermissionStatus(),
      builder: (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data == GeolocationStatus.denied) {
          return Text(
            'Access to location denied',
            textAlign: TextAlign.center,
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("${total_distance.toStringAsFixed(0)}m", style: TextStyle(fontSize: 50.0, fontFamily: "Bebas Neue")),
            ],
          ),
        );
      }
    );
  }
}
