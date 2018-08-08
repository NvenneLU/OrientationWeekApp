import 'package:flutter/material.dart';
import 'ArticleCard.dart';

class CampusSafetyScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.accessibility_new),
        title: Text("Campus Safety"),
        centerTitle: false,
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          )
        ],
      ),
      body: new ListView(children: <Widget>[
        new Card(
          color: Colors.red[900],
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 4.0),
                child: new Row(children: <Widget>[
                  new Icon(Icons.call, color: Colors.white,),
                  new Text(' Campus Security', style: new TextStyle(color: Colors.white, fontSize: 16.0),),
                ],),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(20.0, 4.0, 10.0, 10.0),
                child: new Text("705-673-6562 x 6562", style: new TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0)),
              )
            ],
          ),
        ),
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
      ],),
    );
  }
}