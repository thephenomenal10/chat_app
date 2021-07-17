import 'package:chatApp/screens/chat_screen.dart';
import 'package:chatApp/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _firestore = Firestore.instance;

class HomeScreen extends StatefulWidget {
  static String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        checkOnline(true);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      print("APP iS sed");
      checkOnline(false);
    }
    if (state == AppLifecycleState.resumed) {
      checkOnline(true);
    }
  }

  void checkOnline(bool state) async {
    await _firestore
        .collection("isOnline")
        .document(loggedInUser.email)
        .setData({
      "onlineState": state,
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("⚡️Flash Chat"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                checkOnline(false);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("auth", false);
                Navigator.pushReplacementNamed(context, WelcomeScreen.id);
              })
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection("registeredUsers").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final users = snapshot.data.documents;
          List<Map<String, String>> userList = [];
          for (var user in users) {
            if (loggedInUser.email != user.data["email"]) {
              final name = user.data["name"];
              final email = user.data["email"];
              userList.add({"name": name, "email": email});
              print(name);
              print(email);
            }
          }
          print(userList);
          return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Material(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.blueGrey.shade50,
                          elevation: 1.5,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            recieverEmail: userList[i]["email"],
                                            recieverName: userList[i]["name"],
                                            senderEmail: loggedInUser.email,
                                          )));
                              // Navigator.pushNamed(context, ChatScreen.id,
                              //     arguments: {
                              //       "name": userList[i]["name"],
                              //       "email": userList[i]["email"]
                              //     });
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30.0,
                              child: Hero(
                                transitionOnUserGestures: true,
                                tag: userList[i]["email"],
                                child: Image.network(
                                  "https://www.pngall.com/wp-content/uploads/5/Profile-Avatar-PNG.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            title: Transform.translate(
                                offset: Offset(40, 0),
                                child: Text(
                                  "${userList[i]["name"][0].toString().toUpperCase()}${userList[i]["name"].toString().substring(1).toLowerCase()}",
                                  style: TextStyle(
                                      fontSize: 20, letterSpacing: 1.2),
                                )),
                            subtitle: Transform.translate(
                                offset: Offset(40, 0),
                                child: Text(userList[i]["email"])),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
