import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppStyles.dart';
import 'dart:collection';
import 'package:url_launcher/url_launcher.dart';
import "Route.dart";

class InfoScreen extends StatefulWidget {
  final LanguageCallback callback;
  final ValueNotifier<bool> lang;

  InfoScreen({this.callback, this.lang});


  @override
  InfoScreenState createState() => new InfoScreenState();

}


class InfoScreenState extends State<InfoScreen> {
  String load = "load";
    @override
  initState() {
    super.initState();
    widget.lang.addListener(() {
      
      if(this.mounted) {
        setState(() {
              // load = "load2";
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
    
  }



  Widget getCustomWidget(String key, dynamic v, BuildContext context) {

    String type = key.split("-")[1];
    switch(type) {
      
      case "subtitle":
        return new Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(v[0], style: AppTextStyle.subPrimary,),
              new Text(v[1], style: AppTextStyle.body2MedEmp,),
            ],
          ),
        );
      case "intro":
        return new Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          child: new Column(
            children: <Widget>[
              new Text(v, style: AppTextStyle.bodyMedEmp),
            ],
          ),
        );
        
      case "bullets":

        List<Widget> temp = new List<Widget>();
        if(v[0] != null)
          temp.add(new Text(v[0], style: AppTextStyle.subPrimary,));
        for(var i = 1; i < v.length; i++) {
          if(v[i].toString().contains("tel://")) {
            if(v[i].toString().contains(",")) {
              var one = v[i].toString().split("tel://")[1].substring(0,3);
              var two = v[i].toString().split("tel://")[1].substring(3,6);
              var three = v[i].toString().split("tel://")[1].substring(6,10);
              var ext = v[i].toString().split("tel://")[1].substring(11,15);
              temp.add(new FlatButton(child: Text(one + "-" + two + "-" + three + " ext: " + ext),padding: EdgeInsets.zero, onPressed: () => launch(v[i]),));
            } else {
              if(v[i].toString().split("tel://")[1].length == 10) {
                var one = v[i].toString().split("tel://")[1].substring(0,3);
                var two = v[i].toString().split("tel://")[1].substring(3,6);
                var three = v[i].toString().split("tel://")[1].substring(6,10);
                temp.add(new FlatButton(child: Text(one + "-" + two + "-" + three),padding: EdgeInsets.zero, onPressed: () => launch(v[i]),));
              } else {
                var start = v[i].toString().split("tel://")[1].substring(0,1);
                var one = v[i].toString().split("tel://")[1].substring(1,4);
                var two = v[i].toString().split("tel://")[1].substring(4,7);
                var three = v[i].toString().split("tel://")[1].substring(7,11);
                temp.add(new FlatButton(child: Text(start + "-" + one + "-" + two + "-" + three),padding: EdgeInsets.zero, onPressed: () => launch(v[i]),));
              }
            }
          } else if (v[i].toString().contains("mailto:")){
            temp.add(new FlatButton(child: Text(v[i].toString().split("mailto:")[1]),padding: EdgeInsets.zero, onPressed: () => launch(v[i]),));
          } else if (v[i].toString().contains("http://") || v[i].toString().contains("https://")) {
            temp.add(new FlatButton(child: Text(v[i].toString().split("display:")[1]),padding: EdgeInsets.zero, onPressed: () => launch(v[i].split("display:")[0]),));
          } else {
            temp.add(new Text(v[i], style: AppTextStyle.body2MedEmp,));
          }
        }
      
        return new Container(
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(5.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: temp
          ),
        );
      case "divider":
        return new ListTile(
          title: Text(v, style: AppTextStyle.h5HighEmp),
        );
      case "service":
        List<Widget> temp = new List<Widget>();
        temp.add(new Padding(
          padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Expanded(
                child: new Text(v[0],
                  overflow: TextOverflow.fade,
                  style: AppTextStyle.h6,
                ),
              ),
            ],
          ),
        ),);
        temp.add(new Padding(
          padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
          child: new Row(
            children: <Widget>[
              new Icon(Icons.location_on, color: Colors.grey[600],),
              new Expanded(
                child: new Text(' ' + v[1],
                  style: AppTextStyle.subMedEmp,
                ),
              )
            ],
          ),
        ),);
        temp.add(new Padding(
          padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 14.0),
          child: new Text(v[2],
            style: AppTextStyle.bodyMedEmp,
          ),
        ),);

        for(var i = 3; i < v.length; i++) {
          if(v[i] == null) {
            temp.add(new SizedBox(height: 12.0,));
          } else {
            temp.add(new Padding(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Expanded(
                    child: new Text(v[i], style: AppTextStyle.subMedEmp,),
                  ),
                ],
              ),
            ),);
          }
        }

        temp.add(new ButtonTheme.bar(
          textTheme: ButtonTextTheme.primary,
          child: ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              new OutlineButton( 
                child: new Text("BACK", style: TextStyle(color: CompanyColors.blue),),
                onPressed: () {Navigator.of(context).pop();},
              ),
            ],
          ),
        ));


        return new ListTile(
          title: new Text(v[0], style: AppTextStyle.h6),
          subtitle: new Text(v[1], style: AppTextStyle.subMedEmp,),
          onTap: () {
            Navigator.push(context, PageRouteBuilder(
              opaque: true,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (BuildContext context, _, __) {
                return new Scaffold(
                  appBar: AppBar(
                    leading: Icon(Icons.info),
                    title: Text("Info"),
                    centerTitle: false,
                  ),
                  body: new GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails e) {
                      print(e.velocity.pixelsPerSecond);
                      if(e.velocity.pixelsPerSecond.dx > 1000) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: new ListView(
                      children: <Widget>[
                        new Card(
                          margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 25.0),
                          child: new Container(
                            padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
                            child: new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: temp
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                );
              },
              transitionsBuilder: (_, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
                return SlideTransition(
                  position: new Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: new SlideTransition(
                    position: new Tween<Offset>(
                      begin: Offset.zero,
                      end: const Offset(1.0, 0.0),
                    ).animate(secondaryAnimation),
                    child: child,
                  ),
                );
              }
            ));

          },
          trailing: new Icon(Icons.chevron_right),
        );
      default:
        return new SizedBox(height: 1.0,);
    }


  }


  @override
  Widget build(BuildContext context) {
    if(debugVal.value) {
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.favorite)),
                Tab(icon: Icon(Icons.schedule)),
                Tab(icon: Icon(Icons.contact_phone)),
                Tab(icon: Icon(Icons.home)),
              ],
            ),
            // leading: new Icon(Icons.info),
            // leading: new Icon(Icons.menu),
            title: Text('Info'),
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
          body: TabBarView(
            children: <Widget>[
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/Campus_Safety").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Campus Safety" : "Sécurité sur le campus", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "/HoursOperations" : "F/HoursOperation")).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Hours of operation" : "Heures d'ouverture", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    print(ds);
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);

                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/Contacts").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Support and Contacts" : "Soutiens et personnes contacts", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/ResMoveIn").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Residence Move-In" : "Emménagement en résidence", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
            ],
          ),
        ),
      );
    } else {
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.favorite)),
                Tab(icon: Icon(Icons.schedule)),
                Tab(icon: Icon(Icons.contact_phone)),
                Tab(icon: Icon(Icons.home)),
              ],
            ),
            leading: new Icon(Icons.info),
            title: Text('Info'),
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
          body: TabBarView(
            children: <Widget>[
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/Campus_Safety").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Campus Safety" : "Sécurité sur le campus", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "/HoursOperations" : "F/HoursOperation")).snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Hours of operation" : "Heures d'ouverture", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    print(ds);
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);

                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/Contacts").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Support and Contacts" : "Soutiens et personnes contacts", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
              new StreamBuilder(
                stream: Firestore.instance.document("info" + (widget.lang.value ? "" : "F") + "/ResMoveIn").snapshots(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                    List<Widget> info = new List<Widget>();
                    info.add(new Container(margin: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0), child: Text(widget.lang.value ? "Residence Move-In" : "Emménagement en résidence", style: AppTextStyle.h5,)));
                    DocumentSnapshot ds = snapshot.data;
                    Map<String, dynamic> temp = ds.data;
                    var sortedKeys = temp.keys.toList(growable:false)
                    ..sort((k1, k2) => k1.split("-")[0].compareTo(k2.split("-")[0]));
                    LinkedHashMap sortedMap = new LinkedHashMap
                      .fromIterable(sortedKeys, key: (k) => k, value: (k) => temp[k]);
                    sortedMap.forEach((dynamic t, dynamic v) {
                      info.add(getCustomWidget(t, v, context));
                    });
                    return new ListView(
                      children: info,
                    );
                }   
              ),
            ],
          ),
        ),
      );
    }
  }
}