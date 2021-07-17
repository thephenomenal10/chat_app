import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final String recieverEmail;
  final String recieverName;
  final String senderEmail;

  const ChatScreen(
      {Key key, this.recieverEmail, this.recieverName, this.senderEmail})
      : super(key: key);

  // const ChatScreen({Key key, this.recieverEmail}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String message = "";
  final textController = TextEditingController();
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;

        checkForOtherUserTypingStatus(senderEmail: loggedInUser.email);
        storeInitialStatus();
      }
    } catch (e) {
      print(e);
    }
  }

  void checkForOtherUserTypingStatus({
    String senderEmail,
    bool senderType = false,
  }) async {
    await _firestore
        .collection("isTyping")
        .document("${senderEmail + widget.recieverEmail}")
        .setData({
      "$senderEmail" + "_" + "status": senderType,
      senderEmail: senderEmail
    });
  }

  storeInitialStatus() async {
    await _firestore
        .collection("isTyping")
        .document("${widget.recieverEmail + widget.senderEmail}")
        .setData({
      "${widget.recieverEmail}" + "_" + "status": false,
      widget.recieverEmail: widget.recieverEmail
    });
  }

  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.configure(
      onMessage: (message) {
        print(message);
        return;
      },
      onLaunch: (msg) {
        print(msg);
        return;
      },
      onResume: (msg) {
        print(msg);
        return;
      },
     
    );
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.0),
        child: AppBar(
          leading: null,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Hero(
                  transitionOnUserGestures: true,
                  tag: widget.recieverEmail,
                  child: Image.network(
                    "https://www.pngall.com/wp-content/uploads/5/Profile-Avatar-PNG.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text(
                        "${widget.recieverName[0].toString().toUpperCase()}${widget.recieverName.toString().substring(1).toLowerCase()}",
                        style: TextStyle(letterSpacing: 1.5),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      StreamBuilder(
                          stream: _firestore
                              .collection("isOnline")
                              .document(widget.recieverEmail)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return null;
                            }
                            return snapshot.data["onlineState"]
                                ? Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 15,
                                  )
                                : Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 15,
                                  );
                          })
                    ],
                  ),
                  SizedBox(height: 3),
                  StreamBuilder(
                      stream: _firestore
                          .collection("isTyping")
                          .document(widget.recieverEmail + widget.senderEmail)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return null;
                        }

                        return Text(
                          snapshot.data[
                                  "${widget.recieverEmail}" + "_" + "status"]
                              ? "Typing..."
                              : "",
                          style: TextStyle(fontSize: 12),
                        );
                      })
                ],
              ),
            ],
          ),
          backgroundColor: Colors.lightBlueAccent,
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(withEmail: widget.recieverEmail),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        if (value.length == 0) {
                          checkForOtherUserTypingStatus(
                              senderEmail: loggedInUser.email);
                        } else {
                          checkForOtherUserTypingStatus(
                              senderEmail: loggedInUser.email,
                              senderType: true);
                        }
                        // print(value);
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      checkForOtherUserTypingStatus(
                          senderEmail: loggedInUser.email);
                      _firestore.collection("messages").add({
                        "text": message,
                        "sender": loggedInUser.email,
                        "with": widget.recieverEmail
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final String withEmail;

  const MessageStream({Key key, this.withEmail}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _firestore.collection("messages").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            final messageText = message.data["text"];
            final senderText = message.data["sender"];
            final withText = message.data["with"];
            final currentUser = loggedInUser.email;
            if ((withText == withEmail && currentUser == senderText) ||
                (withText == currentUser && senderText == withEmail)) {
              // print("S E ND E R TE X T");
              // print(senderText);
              // print("M E S S A G E  T E X T");
              // print(messageText);
              final messageBubble = MessageBubble(
                sender: senderText,
                text: messageText,
                isMe: currentUser == senderText,
              );
              messageWidgets.add(messageBubble);
            }
          }
          return Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(reverse: true, children: messageWidgets),
          ));
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  const MessageBubble({Key key, this.sender, this.text, this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(fontSize: 12.0, color: Colors.black45)),
          Material(
            elevation: 6.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    topRight: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0)),
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 20, color: isMe ? Colors.white : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
