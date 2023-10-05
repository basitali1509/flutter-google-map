import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String googleAPIKey = "AIzaSyC0358aIVmuU_omogKareCKAN6R8U31UgY";
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(
    24.96517,
    67.067446,);
  static const LatLng destination = LatLng(24.966292,67.0774);
  final List<Marker> _markers = <Marker>[];

  final Set<Polyline> _polylines={};
  List<LatLng> latlng = [
    sourceLocation,
    destination
  ];

  static const CameraPosition _position = CameraPosition(
      target: LatLng(
          24.966175,67.072481
      ),
      zoom: 15);

  Future<Position> getCurrentLocation() async {
     await Geolocator.requestPermission().then((value) {

    }).onError((error, stackTrace){
      print("error: $error");
    });
    return await Geolocator.getCurrentPosition();
  }

  List<LatLng> polylineCoordinates = [];
  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleAPIKey, // Your Google Map Key
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     PointLatLng(destination.latitude, destination.longitude),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach(
  //           (PointLatLng point) => polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }
  LocationData? currentLocation;
  // void getCurrentLocation() async {
  //   Location location = Location();
  //   location.getLocation().then(
  //         (location) {
  //       currentLocation = location;
  //     },
  //   );
  //   GoogleMapController googleMapController = await _controller.future;
  //   location.onLocationChanged.listen(
  //         (newLoc) {
  //       currentLocation = newLoc;
  //       googleMapController.animateCamera(
  //         CameraUpdate.newCameraPosition(
  //           CameraPosition(
  //             zoom: 13.5,
  //             target: LatLng(
  //               newLoc.latitude!,
  //               newLoc.longitude!,
  //             ),
  //           ),
  //         ),
  //       );
  //       setState(() {});
  //     },
  //   );
  // }
  loadData() async{
    getCurrentLocation().then((value) async {
      print("Lat:${value.latitude} Lon:${value.longitude}");

      GoogleMapController controller = await _controller.future;
      controller.animateCamera(
          CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                  zoom: 17.5)
          )
      );
      setState(() {
        _markers.add(
          Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              markerId: const MarkerId('MyLocation'),
              position: LatLng(
                value.latitude,
                value.longitude,),
              infoWindow: const InfoWindow(
                  title: 'My Location'
              )
          ),
        );
      });

    }).onError((error, stackTrace){
      print('Error: ' + error.toString());
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i =0 ; i<latlng.length; i++){
      _markers.add(
        Marker(
            markerId: MarkerId(i.toString()),
          position: latlng[i],
          infoWindow: InfoWindow(
            title: i.toString(),
            snippet: '5 Star'
          ),
          icon: BitmapDescriptor.defaultMarker
        ),
      );
      _polylines.add(
          Polyline(polylineId: PolylineId('1'),
              points: latlng,
            width: 4,
            color: Colors.blue

          )
      );
    }
    setState(() {

    });

    // loadData();
    // getPolyPoints();

    // _markers.add(
    //   Marker(
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    //       markerId: const MarkerId('SomeId'),
    //       position: const LatLng(
    //         24.96517,
    //         67.067446,),
    //       infoWindow: const InfoWindow(
    //           title: 'The title of the marker'
    //       )
    //   ),
    // );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: GoogleMap(
                initialCameraPosition: _position,
              mapType: MapType.normal,
              myLocationEnabled: true,
              // markers: {
              //   const Marker(
              //     markerId: MarkerId("source"),
              //     position: sourceLocation,
              //   ),
              //   const Marker(
              //     markerId: MarkerId("destination"),
              //     position: destination,
              //   ),
              // },
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
              },
              polylines: _polylines,
              // polylines: {
              //   Polyline(
              //     polylineId: const PolylineId("route"),
              //     points: polylineCoordinates,
              //     color: Colors.blue,
              //     width: 6,
              //   ),
              // },
            )
        ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton(
          child: const Icon(Icons.location_disabled),
            onPressed: ()async{
            getCurrentLocation().then((value) async {
              print("Lat:${value.latitude} Lon:${value.longitude}");

              GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: LatLng(value.latitude, value.longitude),
                          zoom: 17.5)
                  )
              );
              setState(() {
                _markers.add(
                  Marker(
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      markerId: const MarkerId('MyLocation'),
                      position: LatLng(
                        value.latitude,
                        value.longitude,),
                      infoWindow: const InfoWindow(
                          title: 'My Location'
                      )
                  ),
                );
              });

            }).onError((error, stackTrace){
              print('Error: ' + error.toString());
            });

        }),
      ),
    );
  }
}
