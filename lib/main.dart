import 'package:chatApp/screens/auth_screen.dart';
import 'package:chatApp/screens/chat_screen.dart';
import 'package:chatApp/screens/home_screen.dart';
import 'package:chatApp/screens/login_screen.dart';
import 'package:chatApp/screens/register_screen.dart';
import 'package:chatApp/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
      initialRoute: Auth.id,
      routes: {
        Auth.id: (context) => Auth(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        HomeScreen.id: (context) => HomeScreen()
      },
    );
  }
}
