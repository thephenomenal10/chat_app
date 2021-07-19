import 'package:chatApp/screens/home_screen.dart';
import 'package:chatApp/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth extends StatefulWidget {
  static String id = "auth_screen";
  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool auth = false;
  Future<bool> getAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bool authId = false;
      authId = prefs.getBool("auth");
      if (authId == null) authId = false;
      auth = authId;
    });
    print("Auth State" + auth.toString());
    return auth;
  }

  @override
  void initState() {
    super.initState();
    getAuthState();

 
  }

  @override
  Widget build(BuildContext context) {
    return auth ? HomeScreen() : WelcomeScreen();
  }
}
