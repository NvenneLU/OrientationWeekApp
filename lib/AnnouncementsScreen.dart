import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'TimeFormat.dart';
import 'Route.dart';

class AnnouncementsScreen extends StatefulWidget {

  final ValueNotifier<bool> lang;
  final LanguageCallback callback;

  AnnouncementsScreen({this.callback, this.lang});

  @override
  AnnouncementState createState() => new AnnouncementState();

  

  
}

class AnnouncementState extends State<AnnouncementsScreen> {

  String _homeScreenText = "Waiting for token...";
  String collection = 'announcementsE';
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    collection = 'announcements' + (widget.lang.value ? 'E' : 'F');
    widget.lang.addListener(() {
      if(this.mounted) {
        setState(() {
                collection = 'announcements' + (widget.lang.value ? 'E' : 'F');
                _firebaseMessaging.unsubscribeFromTopic("announcements" + (widget.lang.value ? "F" : "E"));
                _firebaseMessaging.subscribeToTopic("announcements" + (widget.lang.value ? "E" : "F"));
              });
      }
    });
    debugVal.addListener(() {
      if(this.mounted) {
        setState(() {
                  print("Swap");
                });
      }
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //               "/announcements", (route) => false);
        print("Test");
      },
      onLaunch: (Map<String, dynamic> message) {
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //               "/announcements", (route) => false);
         print("Test");
      },
      onResume: (Map<String, dynamic> message) {
        // Navigator.of(context).pushNamedAndRemoveUntil(
        //               "/announcements", (route) => false);
         print("Test");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
    _firebaseMessaging.unsubscribeFromTopic("announcements" + (widget.lang.value ? "F" : "E"));
    _firebaseMessaging.subscribeToTopic("announcements" + (widget.lang.value ? "E" : "F"));
  }


  @override
  Widget build(BuildContext context) {
    if(debugVal.value) {
      return Scaffold(
        appBar: AppBar(
          // leading: new Icon(Icons.notifications_active),
          // leading: new Icon(Icons.menu),
          title: Text((widget.lang.value ? 'Announcements' : 'Annonces')),
          centerTitle: false,
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.swap_calls),
              onPressed: () {
                if(debugVal.value){
                  debugVal.value = false;
                } else {
                  debugVal.value = true;
                }
              },
            ),
            new IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'Language',
              onPressed: () {
                if(widget.lang.value) {
                    widget.callback(false);
                    sendAnalyticsEvent("change_language", "Changed to french");
                  } else {
                    widget.callback(true);
                    sendAnalyticsEvent("change_language", "Changed to english");
                  }
              },
            ),
          ],
        ),
        drawer: getDrawer(context),

        body: new StreamBuilder(
          stream: Firestore.instance.collection(collection).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              if(snapshot.data.documents.isEmpty) {
                return new Center(child: Text(widget.lang.value ? "No Announcements" : "Aucune Annonces",));
              }
              var data = snapshot.data.documents.toList(growable: false);
              List<Widget> info = new List<Widget>();
              var sortedKeys = data
              ..sort((k1, k2) => k1['time'].compareTo(k2['time']));

              sortedKeys.reversed.forEach((dynamic v) {
                        info.add(_AnnouncementCard.fromDocument(v));
                      });

              return new ListView(
                padding: EdgeInsets.only(top: 10.0),
                children: info,
              );
          }   
        )
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: new Icon(Icons.notifications_active),
          title: Text((widget.lang.value ? 'Announcements' : 'Annonces')),
          centerTitle: false,
          actions: <Widget>[
            new IconButton(
              icon: Icon(Icons.swap_calls),
              onPressed: () {
                if(debugVal.value){
                  debugVal.value = false;
                } else {
                  debugVal.value = true;
                }
              },
            ),
            new IconButton(
              icon: const Icon(Icons.language),
              tooltip: 'Language',
              onPressed: () {
                if(widget.lang.value) {
                  widget.callback(false);
                } else {
                  widget.callback(true);
                }
              },
            ),
          ],
        ),

        body: new StreamBuilder(
          stream: Firestore.instance.collection(collection).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
              if(snapshot.data.documents.isEmpty) {
                return new Center(child: Text(widget.lang.value ? "No Announcements" : "Aucune Annonces",));
              }
              var data = snapshot.data.documents.toList(growable: false);
              List<Widget> info = new List<Widget>();
              var sortedKeys = data
              ..sort((k1, k2) => k1['time'].compareTo(k2['time']));

              sortedKeys.reversed.forEach((dynamic v) {
                        info.add(_AnnouncementCard.fromDocument(v));
                      });

              return new ListView(
                padding: EdgeInsets.only(top: 10.0),
                children: info,
              );
          }   
        )
      );
    }
  }

}

class _AnnouncementCard extends StatelessWidget {


  final String time;
  final String type;
  final String title;
  final String desc;

  _AnnouncementCard({this.title, this.desc, this.type, this.time}); 

  factory _AnnouncementCard.fromDocument(DocumentSnapshot data) {

    return _AnnouncementCard(
      title: data['title'],
      desc: data['desc'],
      type: data['tag'],
      time: TimeFormat.toAnnouncementTime(data['time']),
    );


  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      margin: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
      child: new Container(
        padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
        child: new Column(
          mainAxisSize:  MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(this.type.toUpperCase(),
                    style: AppTextStyle.ovlnHighEmp,
                  ),
                  new Text(this.time,
                    style: AppTextStyle.ovlnMedEmp,
                  ),
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: Text(this.title, style: AppTextStyle.h5HighEmp), 
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: Text(this.desc, style: AppTextStyle.body2MedEmp),
            ),
            // new ButtonTheme.bar(
            //   textTheme: ButtonTextTheme.primary,
            //   child: new ButtonBar(
            //     alignment: MainAxisAlignment.start,
            //     children: <Widget>[
            //       new FlatButton(
            //         child: new Text('VIEW'),
            //         onPressed: () {},
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}