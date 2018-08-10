import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'ScheduleScreen.dart';
import 'InfoScreen.dart';
import 'AnnouncementsScreen.dart';
import 'ImportantDatesScreen.dart';

int _currentIndex = 2;

ValueNotifier<bool> english = new ValueNotifier<bool>(true);
typedef LanguageCallback(bool en);


ScheduleScreen scheduleScreen = new ScheduleScreen(callback: (en) => english.value = en, lang: english);
ImportantDatesScreen importantDatesScreen = new ImportantDatesScreen(callback: (en) => english.value = en, lang: english);
AnnouncementsScreen announcementsScreen = new AnnouncementsScreen(callback: (en) => english.value = en, lang: english);
InfoScreen infoScreen = new InfoScreen();


Widget getScreen(String settings) {
  switch(settings) {
    case "/":
      return scheduleScreen;
    case '/announcements':
      return announcementsScreen;
    case '/important':
      return importantDatesScreen;
    case '/schedule':
      return scheduleScreen;
    case '/info':
      return infoScreen;
    default:
      var split = settings.split("/");
      print(split);
      if(split[1] == "schedule") {
        int cardID = int.parse(split[2]);
        return EventView(id: cardID);
      }
      return scheduleScreen;
      
  }
}


Route<Null> getRoute(RouteSettings settings) {



  final initialSettings = new RouteSettings(
      name: "/schedule",
      isInitialRoute: true);

  return new MaterialPageRoute<Null>(
      settings: initialSettings,
      builder: (context) =>
      new Scaffold(
        body: getScreen(settings.name),
        // bottomNavigationBar: new BottomNavigationBar(
        //     currentIndex: _currentIndex,
        //     type: BottomNavigationBarType.shifting,
        //     onTap: (value) {
        //       final routes = ["/important", "/announcements", "/schedule", "/info"];
        //       _currentIndex = value;
        //       Navigator.of(context).pushNamedAndRemoveUntil(
        //           routes[value], (route) => false);
        //     },
        //     items: [
        //       new BottomNavigationBarItem(
        //         backgroundColor: CompanyColors.blue,
        //           icon: new Icon(Icons.priority_high), title: new Text("")),
        //       new BottomNavigationBarItem(
        //         backgroundColor: CompanyColors.blue,
        //           icon: new Icon(Icons.notifications_active), title: new Text("")),
        //       new BottomNavigationBarItem(
        //         backgroundColor: CompanyColors.blue,
        //           icon: new Icon(Icons.event), title: new Text("")),
        //       new BottomNavigationBarItem(
        //         backgroundColor: CompanyColors.blue,
        //           icon: new Icon(Icons.info_outline), title: new Text("")),
        //     ],
            
        //     ),
            bottomNavigationBar: new Theme(
              data: Theme.of(context).copyWith(
                  // sets the background color of the `BottomNavigationBar`
                  canvasColor: CompanyColors.blue,
                  // sets the active color of the `BottomNavigationBar` if `Brightness` is light
                  primaryColor: CompanyColors.yellow,
                  textTheme: Theme
                      .of(context)
                      .textTheme
                      .copyWith(caption: new TextStyle(color: Colors.white))), // sets the inactive color of the `BottomNavigationBar`
              child: new BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (value) {
                  final routes = ["/important", "/announcements", "/schedule", "/info"];
                  _currentIndex = value;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      routes[value], (route) => false);
                },
                items: [
                  new BottomNavigationBarItem(
                    backgroundColor: CompanyColors.blue,
                      icon: new Icon(Icons.priority_high), title: new Container(height: 0.0,)),
                  new BottomNavigationBarItem(
                    backgroundColor: CompanyColors.blue,
                      icon: new Icon(Icons.notifications_active), title: new Container(height: 0.0,)),
                  new BottomNavigationBarItem(
                    backgroundColor: CompanyColors.blue,
                      icon: new Icon(Icons.event), title: new Container(height: 0.0,)),
                  new BottomNavigationBarItem(
                    backgroundColor: CompanyColors.blue,
                      icon: new Icon(Icons.info_outline), title: new Container(height: 0.0,)),
                ],
              ),
            ),
        // drawer: Drawer(
        //   child: ListView(
        //     padding: EdgeInsets.zero,
        //     children: <Widget>[
        //       DrawerHeader(
        //         child: Text('Laurentian University', style: new TextStyle(color: Colors.white, fontSize: 25.0),),
        //         decoration: BoxDecoration(
        //           color: CompanyColors.blue,
        //         ),
        //       ),
        //       ListTile(
        //         title: Text((english.value ? 'Schedule' : 'Programme')),
        //         leading: Icon(Icons.event),
        //         onTap: () {
        //           Navigator.of(context).pushNamedAndRemoveUntil(
        //           "/schedule", (route) => false);
        //         },
        //       ),
        //       ListTile(
        //         title: Text((english.value ? 'Important Dates' : 'Dates Importantes')),
        //         leading: Icon(Icons.priority_high),
        //         onTap: () {
        //           Navigator.of(context).pushNamedAndRemoveUntil(
        //           "/important", (route) => false);
        //         },
        //       ),
        //       ListTile(
        //         title: Text((english.value ? 'Announcements' : 'Annonces')),
        //         leading: Icon(Icons.notifications_active),
        //         onTap: () {
        //           Navigator.of(context).pushNamedAndRemoveUntil(
        //           "/announcements", (route) => false);
        //         },
        //       ),
        //       ListTile(
        //         title: Text((english.value ? 'Information' : 'Informations')),
        //         leading: Icon(Icons.info_outline),
        //         onTap: () {
        //           Navigator.of(context).pushNamedAndRemoveUntil(
        //           "/info", (route) => false);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
      )
    );
  }