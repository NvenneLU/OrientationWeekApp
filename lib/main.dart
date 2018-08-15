import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'Route.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer;

void main() => runApp(new MyApp());


class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super (key: key);

  @override
  _MyApp createState() => new _MyApp();
}



class _MyApp extends State<MyApp> {


  

  @override
  void initState() {
      // TODO: implement initState
      super.initState();
      analytics  = new FirebaseAnalytics();
      observer = new FirebaseAnalyticsObserver(analytics: analytics);
      debugVal.addListener(() {
        setState(() {
                  print("Swap");
                });
      });
    }

  

  @override
  Widget build(BuildContext context) =>
      new MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        navigatorObservers: <NavigatorObserver>[observer],
        supportedLocales: [
          const Locale('en', 'US'), // English
          const Locale('fr', 'CA'), // French
        ],
        initialRoute: "/list",
        onGenerateRoute: getRoute,
        
        theme: new ThemeData(
          primarySwatch: CompanyColors.blue,
        accentColor: CompanyColors.yellow,
        backgroundColor: Colors.white,
        ),
      );
}






