import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as https;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'model/homes.dart';

class HomeMap extends StatelessWidget {
  final User _user;
  final List<dynamic>? homes;
  const HomeMap(this.homes, this._user);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: MapDetail(homes, _user),
      ),
    );
  }
}

class MapDetail extends StatefulWidget {
  final List<dynamic>? homes;
  final User _user;
  const MapDetail(this.homes, this._user);
  @override
  _MapDetailState createState() => _MapDetailState();
}

class _MapDetailState extends State<MapDetail> {
  GoogleMapController? myMapController;
  List<Map<String, dynamic>>? propname;
  List<Map<String, dynamic>>? proptypes;
  List<Map<String, dynamic>>? addresses;
  List<Map<String, dynamic>>? locations;
  LatLng mainLocation = LatLng(1.310270, 103.830059);
  double? longitude = 0.0;
  double? latitude = 0.0;
  final Set<Marker> _markers = new Set();

  Set<Marker> myMarker() {
    setState(() {
      widget.homes!.forEach((element) {
        _markers.add(Marker(
          markerId: MarkerId(element['properties_name']),
          position: LatLng(element['latitude']!, element['longitude']!),
          infoWindow: InfoWindow(
            title: element['properties_name'],
            snippet: "Baths:" +
                element['no_of_bathrooms'].toString() +
                "  Rooms:" +
                element['no_of_bedrooms'].toString() +
                " S\$" +
                element['price'].toString(),
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
      }); // forEach
    });
    return _markers;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: mainLocation,
                        zoom: 11.0,
                      ),
                      markers: this.myMarker(),
                      onMapCreated: (controller) {
                        setState(() {
                          myMapController = controller;
                        });
                      },
                    )))));
  }
}
