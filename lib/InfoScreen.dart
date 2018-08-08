import 'package:flutter/material.dart';



class InfoScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.notifications_active),
        title: Text('Info'),
        centerTitle: false,
        actions: <Widget>[
          new IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {},
          ),
        ],
      ),
      body: new Center(child: Text("Test")),
    );
  }
}