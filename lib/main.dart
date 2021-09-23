import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splashscreen/splashscreen.dart';
import 'homelist.dart';
import 'package:poc1/signup.dart';
import 'dart:developer';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LivingCo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: IntroScreen(),
    );
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? result = FirebaseAuth.instance.currentUser;
    return new SplashScreen(
      seconds: 5,
      navigateAfterSeconds:
          //result != null ? HomeList(uid: result.uid) : SignUp(),
          HomeList(uid: 'test'),
      title: new Text('Welcome to LivingCo'),
      image: new Image.network('https://i.imgur.com/pnh0cpW.png'),
      backgroundColor: Colors.blueGrey,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 200.0,
      loaderColor: Colors.greenAccent,
      loadingText: Text("Loading"),
      useLoader: true,
    );
  }
}
