import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'Route.dart';

void main() => runApp(new MyApp());


class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super (key: key);

  @override
  _MyApp createState() => new _MyApp();
}



class _MyApp extends State<MyApp> {

  

  @override
  Widget build(BuildContext context) =>
      new MaterialApp(
        initialRoute: "/list",
        onGenerateRoute: getRoute,
        theme: new ThemeData(
          primarySwatch: CompanyColors.blue,
        accentColor: CompanyColors.yellow,
        backgroundColor: Colors.white,
        ),
      );
}






