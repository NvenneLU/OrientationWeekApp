import 'package:flutter/material.dart';
import 'ArticleCard.dart';

class HealthAndAwarenessScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.favorite),
        title: Text("Health & Awareness"),
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
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
        new ArticleCard(),
      ],),
    );
  }
}

