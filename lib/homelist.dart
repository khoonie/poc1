import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poc1/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poc1/repository/dataRepository.dart';
import 'package:poc1/model/homes.dart';
import 'package:poc1/homeDetails.dart';
import 'dart:developer';

class HomeList extends StatefulWidget {
  final String? uid;
  final String title = "LivingCo";

  HomeList({this.uid});
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  final DataRepository repository = DataRepository();

  @override
  Widget build(BuildContext context) {
    return _buildHome(context);
  }

  Widget _buildHome(BuildContext context) {
    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );

    final bottomAppBar = Container(
        height: 55.0,
        child: BottomAppBar(
            color: Color.fromRGBO(58, 66, 86, 1.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.home, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.blur_on, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.hotel, color: Colors.white)),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.account_box, color: Colors.white)),
                ])));

    final bodyApp = Container(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repository.getStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return _buildList(context, snapshot.data!.docs);
            }));
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: topAppBar,
      bottomNavigationBar: bottomAppBar,
      body: bodyApp,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //TODO add action
        },
        tooltip: 'Do Something',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context,
      List<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem2(context, data)).toList(),
    );
  }

  Widget _buildListItem2(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final home = Home.fromSnapshot(snapshot);
    if (home == null) {
      return Container();
    }
    return Card(
        elevation: 8.0,
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            right: new BorderSide(
                                width: 1.0, color: Colors.white24))),
                    child: _getHomeIcon(home.proptype)),
                title: Text(
                  home.propname == null ? "" : home.propname,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Icon(Icons.linear_scale, color: Colors.yellowAccent),
                    Text(home.proptype, style: TextStyle(color: Colors.white))
                  ],
                ),
                trailing: InkWell(
                    child: Icon(Icons.keyboard_arrow_right,
                        color: Colors.white, size: 30.0),
                    onTap: () {
                      _navigate(BuildContext context) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeDetails(home),
                            ));
                      }

                      _navigate(context);
                    }))));
  }

  Widget _buildListItem(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final home = Home.fromSnapshot(snapshot);
    if (home == null) {
      return Container();
    }

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: InkWell(
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Text(home.propname == null ? "" : home.propname,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold))),
              _getHomeIcon(home.proptype)
            ],
          ),
          onTap: () {
            _navigate(BuildContext context) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeDetails(home),
                  ));
            }

            _navigate(context);
          },
          highlightColor: Colors.green,
          splashColor: Colors.blue,
        ));
  }

  Widget _getHomeIcon(String type) {
    Widget homeIcon;
    if (type == "Condominium") {
      homeIcon = IconButton(
        icon: Icon(Icons.home, color: Colors.white),
        onPressed: () {},
      );
    } else if (type == "Apartment") {
      homeIcon = IconButton(
        icon: Icon(Icons.apartment, color: Colors.white),
        onPressed: () {},
      );
    } else {
      homeIcon = IconButton(
        icon: Icon(Icons.house, color: Colors.white),
        onPressed: () {},
      );
    }
    return homeIcon;
  }
}
