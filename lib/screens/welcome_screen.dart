import 'package:chatApp/screens/home_screen.dart';
import 'package:chatApp/widgets/rounded_button.dart';
import 'package:chatApp/screens/login_screen.dart';
import 'package:chatApp/screens/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore = Firestore.instance;

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);

    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);

    controller.forward();
    controller.addListener(() {
      setState(() {});
      print(controller.value);
    });
  }

  void checkOnline(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String loggedInEmail = await prefs.get("email");
    await _firestore.collection("isOnline").document(loggedInEmail).setData({
      "onlineState": state,
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: "logo",
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60.0,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Flash Chat'],
                  speed: Duration(milliseconds: 250),
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlue,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
              title: "Log In",
            ),
            RoundedButton(
              color: Colors.blue,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
              title: "Register",
            ),
          ],
        ),
      ),
    );
  }
}
