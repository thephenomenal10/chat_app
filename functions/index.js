const functions = require("firebase-functions");
const admin = require("firebase-admin");
// eslint-disable-next-line no-unused-vars

admin.initializeApp();
exports.myFunction = functions.firestore
    .document("messages/{msg}")
    .onCreate(async (snapshot, context) => {
      let myFcm ="";
      console.log(snapshot.data());
      console.log(snapshot.data().with);
      const mailId = snapshot.data().with;
      const withName = snapshot.data().withName;
      const senderMailId = snapshot.data().sender;
      const senderName = snapshot.data().senderName;
      console.log(mailId);
      await admin.firestore()
          .collection("registeredUsers")
          .doc(mailId).get().then((doc) => {
            myFcm = doc.get("fcmToken");
            console.log(" FCM TOKEn" +doc.get("fcmToken"));
          });

      console.log("MYFCM TOKEN " + myFcm);
      const message = {
        notification: {
          title: snapshot.data().sender,
          body: snapshot.data().text,
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
        data: {
          senderName: senderName,
          senderEmail: senderMailId,
          withName: withName,
          withEmail: mailId,
        },
      };
      try {
        return admin.messaging().sendToDevice(myFcm, message);
      } catch (error) {
        return error;
      }
    });
