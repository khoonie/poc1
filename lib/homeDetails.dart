import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:poc1/repository/dataRepository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'model/homes.dart';

typedef DialogCallback = void Function();

class HomeDetails extends StatelessWidget {
  final Home home;
  const HomeDetails(this.home);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(home.propname == null ? "" : home.propname),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: HomeDetailForm(home),
      ),
    );
  }
}

class HomeDetailForm extends StatefulWidget {
  final Home home;
  const HomeDetailForm(this.home);

  @override
  _HomeDetailFormState createState() => _HomeDetailFormState();
}

class _HomeDetailFormState extends State<HomeDetailForm> {
  final DataRepository repository = DataRepository();
  //final _formKey = GlobalKey<FormBuilderState>();
  final dateformat = DateFormat('yyyy-MM-dd');
  final Set<Marker> _markers = new Set();
  GoogleMapController? myMapController;
  CarouselController buttonCarouselController = CarouselController();

  String propname = "";
  String proptype = "";
  String address = "";
  LatLng mainLocation = LatLng(0, 0);
  double longitude = 0.0;
  double latitude = 0.0;

  Set<Marker> myMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(mainLocation.toString()),
        position: mainLocation,
        infoWindow: InfoWindow(
          title: widget.home.propname,
          snippet: widget.home.price,
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
    return _markers;
  }

  @override
  void initState() {
    proptype = widget.home.proptype;
    if (["", null, false, 0].contains(widget.home.longitude)) {
      // default LatLng if one value is empty or null
      longitude = 103.851959;
      latitude = 1.290270;
    } else {
      longitude = double.tryParse(widget.home.longitude)!;
      latitude = double.tryParse(widget.home.latitude)!;
    }
    mainLocation = LatLng(latitude, longitude);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                    child: SizedBox(
                  width: 400.0,
                  height: 400.0,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: mainLocation,
                      zoom: 15.0,
                    ),
                    markers: this.myMarker(),
                    onMapCreated: (controller) {
                      setState(() {
                        myMapController = controller;
                      });
                    },
                  ),
                )))),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.red,
          child: Text('Address',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
        ),
        Container(
          constraints: BoxConstraints.expand(height: 50.0),
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          //color: Colors.red,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              color: Color.fromRGBO(0, 100, 100, 200)),
          child: Text(
            widget.home.address,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            //color: Colors.red,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Text('Asking Price',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic))),
                  Container(
                      child: Text('Property Type',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic))),
                ])),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            //color: Colors.red,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    child: Text(
                  widget.home.price,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                )),
                Container(
                    child: Text(
                  widget.home.proptype,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                )),
              ],
            )),
        Container(
          height:
              250.0, // required because ListView needs a bounding vertical box
          child: ListView(
            children: [
              CarouselSlider(
                  items: [
                    Container(
                      margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://sg2-cdn.pgimgs.com/listing/23597711/UPHO.130111787.V800/116B-Jalan-Tenteram-Balestier-Toa-Payoh-Singapore.jpg'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://sg1-cdn.pgimgs.com/listing/23597711/UPHO.130111786.V800/116B-Jalan-Tenteram-Balestier-Toa-Payoh-Singapore.jpg'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Container(
                      margin: EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://sg1-cdn.pgimgs.com/listing/23597711/UPHO.130111784.V800/116B-Jalan-Tenteram-Balestier-Toa-Payoh-Singapore.jpg'),
                            fit: BoxFit.cover,
                          )),
                    )
                  ],
                  options: CarouselOptions(
                    height: 250.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    viewportFraction: 0.8,
                  ))
            ],
          ),
        ),

        /* Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: CarouselSlider(
              options: CarouselOptions(height: 300.0),
              items: [
                'https://picsum.photos/250?image=8',
                'https://picsum.photos/250?image=7'
              ].map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                            color: Colors.lightGreen,
                            backgroundBlendMode: BlendMode.colorBurn),
                        child: Image.network(i));
                  },
                );
              }).toList()),
        ),*/
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Size (SqF)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Lease Type',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Year Built',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.size,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.leasing,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.yearbuilt,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ))
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Year Built',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Bedrooms',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Bathrooms',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.yearbuilt,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.bedrs,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.baths,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ))
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('PreSchools',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Schools',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Parks',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.presch,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.school,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.parks,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ))
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Hawker Centres',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('MRT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Supermarkets',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.hawks,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.station,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.supermark,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ))
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Malls',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  //color: Colors.red,
                  child: Text('Plot Ratio',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                ),
              ],
            )),
        Container(
            constraints: BoxConstraints.expand(height: 50.0),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                color: Color.fromRGBO(0, 100, 100, 200)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.malls,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
                Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      widget.home.plotRatio,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    )),
              ],
            )),
      ],
    ));

/*    return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: FormBuilder(
            key: _formKey,
            autovalidateMode: AutovalidateMode.always,
            child: Column(children: <Widget>[
              SizedBox(height: 20.0),
              FormBuilderTextField(
                  name: "property name",
                  initialValue: widget.home.propname,
                  decoration: textInputDecoration.copyWith(
                      hintText: "Name", labelText: "Property Name"),
/*                   validator: FormBuilderValidators.compose([
                    FormBuilderValidators.minLength(context, 1),
                    FormBuilderValidators.required(context)
                  ]),*/
                  onChanged: (val) {
                    setState(() => propname = val!);
                  }),
            ]))); */
  }
}
