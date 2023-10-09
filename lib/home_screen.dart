import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //Google API KEY
  final String googleAPIKey = "AIzaSyC0358aIVmuU_omogKareCKAN6R8U31UgY";

  // Controller for Google Map
  final Completer<GoogleMapController> _controller = Completer();
  late LatLng _userLocation;
  late Timer _timer;

  //static source (not used)
  static const LatLng sourceLocation = LatLng(
    24.96517,
    67.067446,
  );

  //Static destination (Will be recieved from cloud database)
  static const LatLng destination = LatLng(24.969503, 67.067073); // change this LatLng as per your location

  //List of Markers
  final List<Marker> _markers = <Marker>[];

  // Set of Polylines
  final Set<Polyline> _polylines = {};

  // List of sources that will be used by polylines
  List<LatLng> latlng = [
    // sourceLocation,
    destination
  ];

  // Initial camera position
  static const CameraPosition _position =
  CameraPosition(target: LatLng(0.0, 0.0), zoom: 15);

  // Function to get current location of user
  Future<Position> getCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print("error: $error");
    });
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  }


  void trackUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      // Add the user's current location as a marker
      _markers.add(
        Marker(
          markerId: MarkerId(userLocation.toString()),
          position: userLocation,
          icon: BitmapDescriptor.defaultMarker,
          // WithHue(BitmapDescriptor.hueViolet),
        ),
      );

      setState(() {});

      // Animate the camera to the user's new location
      // GoogleMapController controller = await _controller.future;
      // controller.animateCamera(
      //   CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //       target: userLocation,
      //       zoom: 18,
      //     ),
      //   ),
      // );
    } catch (e) {
      print("Error getting user location: $e");
    }
  }


  //Function to display user current location in init state.
  loadData() async {
    getCurrentLocation().then((value) async {
      print("Lat:${value.latitude} Lon:${value.longitude}");

      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng((value.latitude + destination.latitude) / 2,
              (value.longitude + destination.longitude) / 2),
          zoom: 17)));
      setState(() {
        _markers.add(
          Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              markerId: const MarkerId('MyLocation'),
              position: LatLng(
                value.latitude,
                value.longitude,
              ),
              infoWindow: const InfoWindow(title: 'My Location')),
        );
      });

      //user's current location to be added in polyline set via latlng list
      latlng.add(LatLng(value.latitude, value.longitude));
    }).onError((error, stackTrace) {
      print('Error: ' + error.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();

    _timer = Timer.periodic(const Duration(seconds: 40), (Timer timer) {
      trackUserLocation();
    });

    // all the locations in latlng is being added in polyline set
    for (int i = 0; i < latlng.length; i++) {
      _markers.add(
        Marker(
            markerId: MarkerId('ID $i'),
            position: latlng[i],
            infoWindow: InfoWindow(title: i.toString(), snippet: 'Destination'),
            icon: BitmapDescriptor.defaultMarker),
      );
      _polylines.add(Polyline(
          polylineId: PolylineId('1'),
          points: latlng,
          width: 4,
          color: Colors.blue));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: GoogleMap(
            initialCameraPosition: _position,
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: Set<Marker>.of(_markers),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);

            },
            polylines: _polylines,
          )),
    );
  }
}