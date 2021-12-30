import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
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
import 'package:flutter_clean_calendar/flutter_clean_calendar.dart';
//import 'package:flutter_clean_calendar/clean_calendar_event.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat_list/chat_list.dart';
import 'authentication.dart';
import 'package:poc1/chat.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    Key? key,
    required this.thumbnail,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle3,
    required this.jsonobj,
    required this.user,
    required this.propid,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String subtitle3;
  final dynamic jsonobj;
  final User user;
  final String propid;

  Future<void> updateAnalytics(User currentUser, int propId) async {
    String tmpStr = '';
    tmpStr = "https://poc-backend-330115.as.r.appspot.com/analytics";

    Map data = {
      "type": "property_view",
      "user_id": currentUser.uid,
      "property_id": propId
    };
    String body = json.encode(data);
    print("Calling Analytics....");
    http.Response response = await http.post(
      Uri.parse(tmpStr),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.statusCode);
      print('Analytics updated for Prop ID: $propId and User $currentUser');
    } else {
      print('Request Failed: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        // margin from edge of the screen, and from each card vertically
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00CCFF),
                    const Color(0xFF000000),
                  ],
                  begin: const Alignment(0.5, -1.5),
                  end: const Alignment(0.5, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp)),
          //color: Color.fromRGBO(64, 75, 96, 0.9)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
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
                    var rec;
                    if (jsonobj is Home) {
                      rec = Recommendations.fromHome(jsonobj);
                    } else {
                      rec = Recommendations.fromJson(jsonobj);
                    }
                    print(propid);
                    updateAnalytics(user, int.parse(propid));
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
  _PropDescription({
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
  NumberFormat formatter = NumberFormat('###,###,000');
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
                'S\$ ' + formatter.format(int.parse(subtitle3)),
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic),
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
  late types.User _chatUser;
  bool _isSigningOut = false;
  int _selectIndex = 0;
  List? _recommendationList;
  String? _savedUrlStr;
  bool _invest = false;
  int _pageNumber = 0;
  late ScrollController _scrollController;
  bool isLoading = false;
  String? showMessage;
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _user = widget._user;
    _chatUser = types.User(id: _user.uid);
    _savedUrlStr = '';
    _invest = false;

    _scrollController = new ScrollController(initialScrollOffset: 5.0)
      ..addListener(_scrollListener);
    super.initState();
  }

  Future<void> _fetchPage() async {
    int nextPageNumber = _pageNumber;
    String urlStr = '';
    if (_invest) {
      showMessage = 'Fetching More Investment Suggestions...';
      urlStr =
          "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/investment/" +
              _user.uid +
              "?page=" +
              nextPageNumber.toString();
    } else {
      showMessage = 'Fetching More Own-Stay Recommendations...';
      urlStr =
          "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/" +
              _user.uid +
              "?page=" +
              nextPageNumber.toString();
    }

    print("--------------------------------");
    print(urlStr);
    print("--------------------------------");

    var url = Uri.parse(urlStr);
    EasyLoading.show(status: showMessage);

    http.Response response = await http.get(url);
    EasyLoading.dismiss();

    if (response.statusCode == 200) {
      var tempResponse = response.body.replaceAll('NaN', '""');
      var jsonResponse = convert.jsonDecode(tempResponse);
      var recommendations = jsonResponse['recommendations'];
      nextPageNumber = _pageNumber + 1;
      EasyLoading.showSuccess("Done. Please keep Scrolling.");
      this.setState(() {
        if (_recommendationList != null) {
          _recommendationList!.addAll(recommendations);
        }
        _pageNumber = nextPageNumber;
        isLoading = false;
      });
    } else {
      print('Request Failed: ${response.statusCode}');
      EasyLoading.showError("Server Busy, Please try again");

      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pullRefresh() async {
      this.setState(() {
        //_recommendationList!.clear();
        _pageNumber = 0;
      });
      String urlStr = '';
      if (_invest) {
        urlStr =
            "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/investment/" +
                _user.uid +
                "?page=0";
      } else {
        urlStr =
            "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/" +
                _user.uid +
                "?page=0";
      }

      print(urlStr);
      var url = Uri.parse(urlStr);
      EasyLoading.show(status: 'Refreshing, Please Wait...');
      http.Response response = await http.get(url);
      EasyLoading.dismiss();
      if (response.statusCode == 200) {
        EasyLoading.showSuccess("Recommendation Ready");
        var tempResponse = response.body.replaceAll('NaN', '""');
        var jsonResponse = convert.jsonDecode(tempResponse);
        var recommendations = jsonResponse['recommendations'];
        _recommendationList!.clear();
        this.setState(() {
          _recommendationList = recommendations;
          _pageNumber = 1;
          print(_recommendationList);
        });
      } else {
        print('Request Failed: ${response.statusCode}');
        EasyLoading.showError("Server Busy, Please Try Again Later");
      }
    }

    Future<String> showErrorDialog() async {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text(
              'Server Busy. Discard survey or try getting recommendations again?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Retry');
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    Future<void> getPredictionV2(User currentUser, String urlStr) async {
      /// This only needs user and page as GET params
      String? showMessage;
      bool retryCall = true;

      if (urlStr != '') {
        if (_invest) {
          showMessage = 'Calculating Investment Suggestions...';
          urlStr =
              "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/investment/" +
                  currentUser.uid +
                  "?page=0";
        } else {
          showMessage = 'Calculating Own-Stay Recommendations...';
          urlStr =
              "https://poc-backend-330115.as.r.appspot.com/v2/recommendation/" +
                  currentUser.uid +
                  "?page=0";
        }
        print('****** The URL to call is $urlStr');
        var url = Uri.parse(urlStr);
        while (retryCall) {
          EasyLoading.show(status: showMessage);
          http.Response response = await http.get(url);
          EasyLoading.dismiss();
          if (response.statusCode == 200) {
            EasyLoading.showSuccess("Ready - Please go to Recommendations");
            var tempResponse = response.body.replaceAll('NaN', '""');
            var jsonResponse = convert.jsonDecode(tempResponse);
            var recommendations = jsonResponse['recommendations'];

            this.setState(() {
              _recommendationList = recommendations;
              print(_recommendationList);
            });
            retryCall = false;
            //var result = await showErrorDialog();
            //print(result);
          } else {
            print('Request Failed: ${response.statusCode}');
            //EasyLoading.showError("Server Busy , Please Try Again");
            var result = await showErrorDialog();
            print(result);
            if (result == 'Discard') {
              retryCall = false;
            }
          }
        }
      }
    }

    Future<void> updateUserProfile(
        User currentUser, String urlStr, bool invest) async {
      String tmpStr = '';
      print("is this an investment property?");
      print(invest);
      if (urlStr != '') {
        /// survey wasn't cancelled
        ///
        /// Data was constructed in parameters, so convert back to variables
        tmpStr = "https://poc-backend-330115.as.r.appspot.com/recommendation?" +
            urlStr;
        var url = Uri.parse(tmpStr);

        Map data = {
          'age': url.queryParameters['age'],
          'married': url.queryParameters['married'],
          'kids_below_7': url.queryParameters['kids_below_7'],
          'kids_between_7_and_12': url.queryParameters['kids_between_7_and_12'],
          'household_size': url.queryParameters['household_size'],
          'household_income': url.queryParameters['household_income'],
        };
        String body = json.encode(data);

        urlStr = "https://poc-backend-330115.as.r.appspot.com/user/profile/" +
            currentUser.uid;
        EasyLoading.show(status: 'Updating Profile, Please Wait...');
        http.Response response = await http.post(
          Uri.parse(urlStr),
          headers: <String, String>{
            "Content-Type": "application/json; charset=UTF-8"
          },
          body: body,
        );
        EasyLoading.dismiss(animation: true);
        if (response.statusCode == 200) {
          EasyLoading.instance.displayDuration =
              const Duration(milliseconds: 2000);
          EasyLoading.showInfo("Profile Updated - Getting Recommendations");
          getPredictionV2(_user, urlStr);
        } else {
          print('Request Failed: ${response.statusCode}');
          EasyLoading.showError("Profile Update Failed");
        }
      }
    }

    Future<void> getPredictionV1(String urlStr, bool invest) async {
      print("is this an investment property?");
      print(invest);
      if (urlStr != '') {
        // survey not cancelled
        urlStr =
            "https://poc-backend-330115.as.r.appspot.com/recommendation?page=0&" +
                urlStr +
                "&userid=" +
                _user.uid;
        var url = Uri.parse(urlStr);
        print("Userid = " + _user.uid);
        EasyLoading.show(status: 'Calculating, Please Wait...');
        http.Response response = await http.get(url);
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Recommendations Ready");
        if (response.statusCode == 200) {
          var tempResponse = response.body.replaceAll('NaN', '""');
          var jsonResponse = convert.jsonDecode(tempResponse);
          var recommendations = jsonResponse['recommendations'];

          this.setState(() {
            _recommendationList = recommendations;
            print(_recommendationList);
          });
        } else {
          print('Request Failed: ${response.statusCode}');
          EasyLoading.showError("Request Failed");
          //showSimpleNotification(Text("Error Calculating Recommendation"),
          //  background: Colors.red, duration: Duration(seconds: 5));
        }
      }
    }

    final topAppBar = AppBar(
      elevation: 0.1,
      backgroundColor: Colors.blue.shade100,
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
          backgroundColor: Colors.blue,
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
        color: _invest == true ? Colors.green.shade200 : Colors.blue.shade200,
        child: RefreshIndicator(
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 20.0),
              itemCount:
                  _recommendationList == null ? 0 : _recommendationList!.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomListItem(
                    thumbnail: Image.network(
                      'https://images.unsplash.com/photo-1475855581690-80accde3ae2b?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=400&fit=max',
                    ),
                    //_getHomeIcon(_recommendationList![index]['property_type']),
                    title: _recommendationList![index]['properties_name'] +
                        (_recommendationList![index]['subdistrict'] == 'nan'
                            ? ''
                            : ' (' +
                                _recommendationList![index]['subdistrict'] +
                                ')'),
                    subtitle1: _recommendationList![index]['no_of_bedrooms']
                            .toString() +
                        ' Bedrooms   ' +
                        _recommendationList![index]['no_of_bathrooms']
                            .toString() +
                        ' Bathrooms',
                    subtitle2: _recommendationList![index]['size'].toString() +
                        ' SqFeet',
                    subtitle3: _recommendationList![index]['price'].toString(),
                    jsonobj: _recommendationList![index],
                    user: _user,
                    propid:
                        _recommendationList![index]['property_id'].toString());
              }),
          onRefresh: _pullRefresh,
        ));

    final surveyApp = Scaffold(
        backgroundColor: Colors.blue.shade100,
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
                padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
                child: SignInButtonBuilder(
                  icon: Icons.content_paste_outlined,
                  text: 'Click to Start the Survey',
                  backgroundColor: Colors.blueGrey,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LivingCoSurvey(
                                  user: _user,
                                ))).then((value) {
                      print(value); // URL string
                      /// after returning from Survey save the url values
                      /// and the investment or self-purchase boolean value

                      setState(() {
                        _savedUrlStr = value["url"];
                        _invest = value["invest"];
                      });

                      /// update the user profile for v2
                      updateUserProfile(_user, value["url"], value["invest"]);

                      /// go get the prediction based on the returned values for v1
                      //getPrediction(value["url"], value["invest"]);
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

    final Map<DateTime, List<CleanCalendarEvent>> _events = {
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
        CleanCalendarEvent('House Viewing Appointment',
            startTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, 10, 0),
            endTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day, 12, 0),
            description: 'Meet with Miss Chamberlane at Orchard Rd',
            color: Colors.blue.shade700),
      ],
      DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 2): [
        CleanCalendarEvent('New Condo Launch Reception',
            startTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 2, 10, 0),
            endTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 2, 12, 0),
            description: 'Launch event at New World Center',
            color: Colors.orange),
        CleanCalendarEvent('House Viewing Appointment',
            startTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 2, 14, 30),
            endTime: DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 2, 17, 0),
            description: 'Meet with Mr Chiu at Beduk',
            color: Colors.pink),
      ],
    };

    void _handleNewDate(date) {
      print('Date selected: $date');
    }

    final scheduleApp = Container(
      child: Calendar(
        startOnMonday: true,
        weekDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        events: _events,
        onRangeSelected: (range) =>
            print('Range is ${range.from}, ${range.to}'),
        onDateSelected: (date) => _handleNewDate(date),
        isExpandable: true,
        selectedColor: Colors.pink,
        todayColor: Colors.blue,
        eventColor: Colors.grey,
        locale: 'en_US',
        todayButtonText: 'Today',
        expandableDateFormat: 'EEEE, dd. MMMM yyyy',
        dayOfWeekStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );

    final agentIntroApp = Container(child: (Text('Agent Intro and Promo')));

    final ScrollController _chatScrollController = ScrollController();
    final List<Message> _messageList = [
      Message(
          content: "Hey can I view this house?",
          ownerType: OwnerType.sender,
          ownerName: "HomeBuyer1"),
      Message(
          content: "Sure, let's set up an appointment",
          textColor: Colors.black38,
          fontSize: 18.0,
          ownerType: OwnerType.receiver,
          ownerName: "Agent1"),
      Message(
          content:
              "Can we meet at 3pm, at the corner of X and Y street? My contact is 111-222-333",
          ownerType: OwnerType.sender,
          ownerName: "HomeBuyer1"),
      Message(
          content: "No problem I have you down for 3pm. See you then!",
          textColor: Colors.black38,
          fontSize: 18.0,
          ownerType: OwnerType.receiver,
          ownerName: "Agent1"),
      Message(
          content: "Great, have a nice day.",
          ownerType: OwnerType.sender,
          ownerName: "HomeBuyer1"),
    ];

    void _handlePressed(types.User otherUser, BuildContext context) async {
      final room = await FirebaseChatCore.instance.createRoom(otherUser);
      print(room);
      _navigate(BuildContext context, types.Room room, types.User user) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FlyerChat(room: room, user: user)));
      }

      _navigate(context, room, otherUser);
    }

    Widget _buildContactList(BuildContext context, types.User user) {
      return Card(
        elevation: 3.0,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration:
              const BoxDecoration(color: Color.fromRGBO(34, 105, 196, 0.9)),
          child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: Container(
                  padding: const EdgeInsets.only(right: 12.0),
                  decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(width: 1.0, color: Colors.white))),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.withOpacity(0.9),
                      child: Image.network(
                        user.imageUrl!,
//                        _firebaseUser.photoURL!,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )),
              title: Text(
                user.firstName!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: <Widget>[
                  const Icon(Icons.linear_scale, color: Colors.yellow),
                  Text(
                      DateTime.fromMillisecondsSinceEpoch(
                              user.createdAt!.toInt())
                          .toString(),
                      style: const TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: InkWell(
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                    size: 30.0,
                  ),
                  onTap: () {
                    print(user);
                    _handlePressed(user, context);
                  })),
        ),
      );
    }

    final chatListApp = StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          return ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: 20.0),
            children: snapshot.data!
                .map((e) => _buildContactList(context, e))
                .toList(),
          );
        });

    final agentChatApp = Container(
        child: ChatList(
            children: _messageList, scrollController: _chatScrollController));

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
          children: [scheduleApp, agentIntroApp, chatListApp],
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
        selectedIconTheme: IconThemeData(color: Colors.white, size: 40),
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blue.shade200,
        backgroundColor: Colors.blue.shade700,
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

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        isLoading = true;
      });
      print("Comes to bottom $isLoading");
      _fetchPage();
    }
  }

  Widget _buildList(BuildContext context,
      List<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem3(context, data)).toList(),
    );
  }

  Widget _buildListItem3(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final home = Home.fromSnapshot(snapshot);
    if (home == null) {
      return Container();
    }
    return CustomListItem(
        thumbnail: _getHomeIcon(home.proptype),
        title: home.propname == null ? "" : home.propname,
        subtitle1: home.bedrs + ' Bedrooms   ' + home.baths + ' Bathrooms',
        subtitle2: home.size + ' SqFeet',
        subtitle3: home.price,
        jsonobj: home,
        user: _user,
        propid: home.id);
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
                              builder: (context) => HomeDetails(home, _user),
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
                    builder: (context) => HomeDetails(home, _user),
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
