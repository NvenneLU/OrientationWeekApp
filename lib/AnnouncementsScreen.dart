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
      setState(() {
              collection = 'announcements' + (widget.lang.value ? 'E' : 'F');
            });
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
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
    _firebaseMessaging.subscribeToTopic("announcements");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.notifications_active),
        title: Text('Announcements'),
        centerTitle: false,
        actions: <Widget>[
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
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
            return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                print(ds.data['time']);
                
                return new _AnnouncementCard.fromDocument(ds);
              }
            );
        }   
      )
    );
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
            new ButtonTheme.bar(
              textTheme: ButtonTextTheme.primary,
              child: new ButtonBar(
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  new FlatButton(
                    child: new Text('VIEW'),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}