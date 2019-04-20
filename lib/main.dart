import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool mapToggle = false;
  Geolocator _geolocator = new Geolocator();

  Future<GeolocationStatus>_getPermission() async {
    final GeolocationStatus result = await _geolocator.checkGeolocationPermissionStatus();
    return result;
  }

  Future<Position>_getLocation() {
    return _getPermission().then((result) async{
      Position coords = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      );
      return coords;
    });
  }

  Future<Position>_buildMap() async{
    return _getLocation().then((response) {
      return response;
    });
  }

  // @override
  void initState() {
    super.initState();
    setState(() {
      mapToggle = true; 
    });
  }

  @override
  Widget build(BuildContext context) {

    var futureBuilder = new FutureBuilder(
      future: _buildMap(), //_myStream(),
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            if (snapshot.hasData) {
              return new FlutterMap(
                  options: new MapOptions(
                    center: new LatLng(snapshot.data.latitude, snapshot.data.longitude),
                    minZoom: 10.0
                  ),
                  layers: [
                    new TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']
                    ),
                    new MarkerLayerOptions(
                      markers: [
                        new Marker(
                          width: 45.0,
                          height: 45.0,
                          point: new LatLng(snapshot.data.latitude, snapshot.data.longitude),
                          builder: (context) => new Container(
                            child: IconButton(
                              icon: Icon(Icons.location_on),
                              color: Colors.red,
                              iconSize: 45.0,
                              onPressed: () {
                                print("Marker Tapped");
                              },
                            ),
                          )
                        )
                      ]
                    ),
                  ]
              );
            }
        }
    },);

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Leaflet Map'),
      ),
      body: new Column(
        children: <Widget>[
          Stack( children: <Widget>[
            Container(
                    height: MediaQuery.of(context).size.height - 100.0,
                    width: double.infinity,
                    // Wrap with stream builder could be sloved your problem...
                    child: mapToggle ? futureBuilder : Center(child: 
                        Text('Loading...Please wait', style: TextStyle(
                          fontSize: 20.0
                        ),
                      ),
                    )
                  ),
          ], )
        ],
      )
        
    );
  }
}