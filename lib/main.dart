import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:poc1/signup.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /*   return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User user = snapshot.data!;
            if (user == null) {
              return SignInPage();
            }
            return HomePage();
          } else {
            return Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
          }
        });
*/
    return OverlaySupport.global(
        child: MaterialApp(
      title: 'LivingCo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color.fromRGBO(58, 66, 86, 1.0)),
      home: IntroScreen(),
      builder: EasyLoading.init(),
    ));
  }
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //User? result = FirebaseAuth.instance.currentUser;
    return EasySplashScreen(
      logo: Image.network(
        'https://i.imgur.com/pnh0cpW.png',
        height: 200,
      ),

      title: Text(
        "LivingCo",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey.shade400,
      showLoader: true,
      loadingText: Text("Please wait..."),
      //navigator: HomeList(uid: 'test'),
      navigator: SignUp(),
      durationInSeconds: 2,
    );
  }
}
