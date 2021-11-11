import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:poc1/recommendationDetails.dart';
import 'package:poc1/repository/dataRepository.dart';
import 'package:poc1/model/homes.dart';
import 'package:poc1/model/recommendations.dart';
import 'package:poc1/homeDetails.dart';
import 'package:poc1/signup.dart';
import 'package:poc1/survey.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:overlay_support/overlay_support.dart';

import 'authentication.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    Key? key,
    required this.thumbnail,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle3,
    required this.jsonobj,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String subtitle3;
  final dynamic jsonobj;
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        // margin from edge of the screen, and from each card vertically
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, 0.9)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: thumbnail,
              ),
              Expanded(
                flex: 4,
                child: _PropDescription(
                    title: title,
                    subtitle1: subtitle1,
                    subtitle2: subtitle2,
                    subtitle3: subtitle3),
              ),
              InkWell(
                  child: Icon(Icons.keyboard_arrow_right,
                      color: Colors.white, size: 50.0),
                  onTap: () {
                    final rec = Recommendations.fromJson(jsonobj);
                    _navigate3(BuildContext context) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendationDetails(rec),
                          ));
                    }

                    _navigate3(context);
                  }),
            ],
          ),
        ));
  }
}

class _PropDescription extends StatelessWidget {
  const _PropDescription({
    Key? key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle3,
  }) : super(key: key);

  final String title;
  final String subtitle1;
  final String subtitle2;
  final String subtitle3;

  @override
  Widget build(BuildContext context) {
    return Padding(
        // distance of wordings from edge of card
        padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
              Text(
                subtitle1,
                style: const TextStyle(color: Colors.white60, fontSize: 13.0),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
              Text(
                subtitle2,
                style: const TextStyle(color: Colors.white60, fontSize: 13.0),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
              Text(
                subtitle3,
                style:
                    const TextStyle(color: Colors.greenAccent, fontSize: 13.0),
              ),
            ]));
  }
}

class HomeList extends StatefulWidget {
  const HomeList({Key? key, required User user})
      : _user = user,
        super(key: key);

  final User _user;

  final String title = "LivingCo";
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  final DataRepository repository = DataRepository();
  late User _user;
  bool _isSigningOut = false;
  int _selectIndex = 0;
  List? _recommendationList;
  String? _savedUrlStr;

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignUp(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
      print(index);
    });
  }

  @override
  void initState() {
    _user = widget._user;
    _savedUrlStr = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pullRefresh() async {
      this.setState(() {
        _recommendationList!.clear();
      });
      String urlStr =
          "https://poc-backend-330115.as.r.appspot.com/recommendation?" +
              _savedUrlStr!;
      var url = Uri.parse(urlStr);
      showSimpleNotification(Text("Refreshing Recommendations"),
          background: Colors.blue, duration: Duration(seconds: 5));
      http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        showSimpleNotification(Text("Recommendation Ready"),
            background: Colors.green, duration: Duration(seconds: 5));
        var tempResponse = response.body.replaceAll('NaN', '""');
        var jsonResponse = convert.jsonDecode(tempResponse);
        var recommendations = jsonResponse['recommendations'];

        this.setState(() {
          _recommendationList = recommendations;
          print(_recommendationList);
        });
      } else {
        print('Request Failed: ${response.statusCode}');
        showSimpleNotification(Text("Error Calculating Recommendation"),
            background: Colors.red, duration: Duration(seconds: 5));
      }
    }

    Future<void> getPrediction(String urlStr) async {
      if (urlStr != '') {
        // survey not cancelled
        urlStr = "https://poc-backend-330115.as.r.appspot.com/recommendation?" +
            urlStr;
        var url = Uri.parse(urlStr);

        showSimpleNotification(Text("Calculating Recommendation"),
            background: Colors.blue, duration: Duration(seconds: 5));

        http.Response response = await http.get(url);

        if (response.statusCode == 200) {
          showSimpleNotification(Text("Recommendation Ready"),
              background: Colors.green, duration: Duration(seconds: 5));
          var tempResponse = response.body.replaceAll('NaN', '""');
          var jsonResponse = convert.jsonDecode(tempResponse);
          var recommendations = jsonResponse['recommendations'];

          this.setState(() {
            _recommendationList = recommendations;
            print(_recommendationList);
          });
        } else {
          print('Request Failed: ${response.statusCode}');
          showSimpleNotification(Text("Error Calculating Recommendation"),
              background: Colors.red, duration: Duration(seconds: 5));
        }
      }
    }

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Color.fromRGBO(58, 66, 86, 0.0),
      title: Image.asset(
        'assets/icon/Seeker Logo.png',
        height: 64,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.list),
          onPressed: () {},
        )
      ],
    );

    final listApp = Container(
        color: Colors.blueGrey,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repository.getStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              return _buildList(context, snapshot.data!.docs);
            }));
    final promoApp = Container(child: (Text('Best Sellers')));
    final popularApp = Container(child: (Text('Popular')));
    final listAppSelections = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Listing'),
                  Tab(text: 'Promotions'),
                  Tab(text: 'Popular'),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [listApp, promoApp, popularApp],
        ),
      ),
    );

    final recommendApp = Container(
        color: Colors.blueAccent,
        child: RefreshIndicator(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20.0),
              itemCount:
                  _recommendationList == null ? 0 : _recommendationList!.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomListItem(
                  thumbnail: _getHomeIcon(
                      _recommendationList![index]['property_type']),
                  title: _recommendationList![index]['properties_name'] +
                      (_recommendationList![index]['subdistrict'] == 'nan'
                          ? ''
                          : ' (' +
                              _recommendationList![index]['subdistrict'] +
                              ')'),
                  subtitle1:
                      _recommendationList![index]['no_of_bedrooms'].toString() +
                          ' Bedrooms   ' +
                          _recommendationList![index]['no_of_bathrooms']
                              .toString() +
                          ' Bathrooms',
                  subtitle2: _recommendationList![index]['size'].toString() +
                      ' SqFeet',
                  subtitle3:
                      'S\$ ' + _recommendationList![index]['price'].toString(),
                  jsonobj: _recommendationList![index],
                );
              }),
          onRefresh: _pullRefresh,
        ));

    final surveyApp = Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text("LivingCo Survey",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  fontFamily: 'Roboto')),
        ),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
              "This survey will gather information to help us better understand the properties you seek",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Roboto')),
        ),
        Padding(
            padding: EdgeInsets.all(10.0),
            child: SignInButtonBuilder(
              icon: Icons.surfing,
              text: 'Start the Survey',
              backgroundColor: Colors.blueGrey,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LivingCoSurvey(
                              user: _user,
                            ))).then((value) {
                  print(value); // URL string
                  setState(() {
                    _savedUrlStr = value;
                  });
                  getPrediction(value);
                });
              },
            )),
      ],
    )));

    final ideasAppSelections = DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Survey'),
                  Tab(text: 'Recommendations'),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [surveyApp, recommendApp],
        ),
      ),
    );

    final magazineApp = Container(child: (Text('Magazine')));
    final statsApp = Container(child: (Text('Statistics')));
    final newProjectsApp = Container(child: (Text('New Projects/Promo')));
    final newsAppSelections = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Magazine'),
                  Tab(text: 'Ind Statistics'),
                  Tab(text: 'New Projects'),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [magazineApp, statsApp, newProjectsApp],
        ),
      ),
    );

    final scheduleApp = Container(child: (Text('Scheduler')));
    final agentIntroApp = Container(child: (Text('Agent Intro and Promo')));
    final agentChatApp = Container(child: (Text('Agent Chat')));
    final agentsAppSelections = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Schedules'),
                  Tab(text: 'Agent YouTube'),
                  Tab(text: 'Agent Chat'),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [scheduleApp, agentIntroApp, agentChatApp],
        ),
      ),
    );

    final accApp = Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(),
                    _user.photoURL != null
                        ? ClipOval(
                            child: Material(
                              color: Colors.orange.withOpacity(0.3),
                              child: Image.network(
                                _user.photoURL!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Material(
                              color: Colors.orange.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ),
                          ),
                    SizedBox(height: 16.0),
                    Text(
                      'Logged in as',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      _user.displayName!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text('(${_user.email!})',
                        style: (TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          letterSpacing: 0.5,
                        ))),
                    SizedBox(height: 16.0),
                    _isSigningOut
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : Padding(
                            padding: EdgeInsets.all(1.0),
                            child: SignInButtonBuilder(
                              text: "Logout From LivingCo",
                              icon: Icons.logout,
                              onPressed: () async {
                                setState(() {
                                  _isSigningOut = true;
                                });
                                await Authentication.signOut(context: context);
                                setState(() {
                                  _isSigningOut = false;
                                });
                                Navigator.of(context)
                                    .pushReplacement(_routeToSignInScreen());
                              },
                              backgroundColor: Colors.blueGrey[700]!,
                            )),
                  ],
                ))));

    final List<Widget> _pages = <Widget>[
      listAppSelections,
      ideasAppSelections,
      newsAppSelections,
      agentsAppSelections,
      accApp
    ];

    return Scaffold(
      appBar: topAppBar,
//      appBar: AppBar(
//        title: const Text('Living Co Listing'),
//      ),
      body: IndexedStack(
        //child: _pages.elementAt(_selectIndex),
        index: _selectIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 15,
        selectedIconTheme: IconThemeData(color: Colors.amberAccent, size: 40),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedItemColor: Colors.amberAccent,
        backgroundColor: Colors.orangeAccent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Ideas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.real_estate_agent),
            label: 'Agents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Account',
          ),
        ],
        currentIndex: _selectIndex,
        onTap: _onItemTapped,
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
        icon: Icon(
          Icons.home,
          color: Colors.white,
          size: 50.0,
        ),
        onPressed: () {},
      );
    } else if (type == "Apartment") {
      homeIcon = IconButton(
        icon: Icon(
          Icons.apartment,
          color: Colors.white,
          size: 40.0,
        ),
        onPressed: () {},
      );
    } else {
      homeIcon = IconButton(
        icon: Icon(
          Icons.house,
          color: Colors.white,
          size: 40.0,
        ),
        onPressed: () {},
      );
    }
    return homeIcon;
  }
}
