import 'package:chatApp/constants.dart';
import 'package:chatApp/screens/home_screen.dart';
import 'package:chatApp/widgets/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'register_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;

  final _firestore = Firestore.instance;
  String email = "", password = "", name = "";
  bool loading = false;
  final key = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: "logo",
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  name = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: "Enter your name")),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //Do something with the user input.
                  email = value;
                },
                keyboardType: TextInputType.emailAddress,
                decoration: kTextFieldDecoration.copyWith(
                  hintText: "Enter your email",
                )),
            SizedBox(
              height: 8.0,
            ),
            TextField(
              textAlign: TextAlign.center,
              obscureText: true,
              onChanged: (value) {
                //Do something with the user input.
                password = value;
              },
              decoration: kTextFieldDecoration.copyWith(
                  hintText: "Enter your password"),
            ),
            SizedBox(
              height: 24.0,
            ),
            loading
                ? Center(child: CircularProgressIndicator())
                : RoundedButton(
                    title: "Register",
                    color: Colors.blueAccent,
                    onPressed: () async {
                      try {
                        setState(() {
                          loading = true;
                        });
                        final newUser =
                            await _auth.createUserWithEmailAndPassword(
                                email: email, password: password);
                        if (newUser != null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool("auth", true);
                          prefs.setString("email", email);
                          await _firestore.collection("registeredUsers").add({
                            "name": name,
                            "email": email,
                            "password": password
                          });
                          Navigator.pushReplacementNamed(
                              context, HomeScreen.id);
                          setState(() {
                            loading = true;
                          });
                        }
                      } catch (e) {
                        setState(() {
                          loading = false;
                        });
                        key.currentState.showSnackBar(new SnackBar(
                          backgroundColor: Colors.blueGrey,
                          content: new Text(
                            e.message,
                            style: TextStyle(color: Colors.white),
                          ),
                        ));
                        print(e);
                      }
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
