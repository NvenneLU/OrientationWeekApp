import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'AppStyles.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'TimeFormat.dart';
import 'Route.dart';
import 'package:flutter/services.dart';

DeviceCalendarPlugin _deviceCalendarPlugin;
Calendar _selectedCalendar;
List<Calendar> _calendars;


class ImportDate {
  final String name;
  final DateTime start;
  final DateTime end;


  ImportDate({this.name, this.start, this.end});

  factory ImportDate.fromJson(Map<String, dynamic> json) {
    var startTemp;
    var endTemp;
    var length = json['start']['date'].toString();
    if(length.length == 4) {
      startTemp = json['start']['dateTime'].toString().split("T")[0];
      endTemp = json['end']['dateTime'].toString().split("T")[0];
    } else {
      startTemp = json['start']['date'];
      endTemp = json['end']['date'];
    }
    return ImportDate(
      name: json['summary'],
      start: DateTime.parse(startTemp),
      end: DateTime.parse(endTemp),
    );
  }
}

List<ImportDate> saveDates;


class ImportantDatesScreen extends StatefulWidget {

  final LanguageCallback callback;
  final ValueNotifier<bool> lang;

  ImportantDatesScreen({this.callback, this.lang});


  @override
  ImportantDatesState createState() => new ImportantDatesState();

}

class ImportantDatesState extends State<ImportantDatesScreen> {

  ImportantDatesState() {
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
  }

  void _retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      setState(() {
        _calendars = calendarsResult?.data;
        _selectedCalendar = _calendars[0];
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }


  String fr = "laurentian.ca_7uqfoldfh55ml6gsvbvui7bdac@group.calendar.google.com";
  String en = "laurentian.ca_62rsj0ue19b2kflvsigkjrk4ac@group.calendar.google.com";
  String url;

  @override
  initState() {
    super.initState();
    _retrieveCalendars();

    url = "https://www.googleapis.com/calendar/v3/calendars/" + (widget.lang.value ? en : fr) +"/events/?key=AIzaSyA9oGfxEwtmM7t5xlnCYjuuy5polbueWnI&timeMin=2018-08-01T15%3A19%3A21%2B00%3A00&timeMax=2019-06-30T15%3A19%3A21%2B00%3A00";

    widget.lang.addListener(() {
      if(this.mounted) {
        setState(() {
                url = "https://www.googleapis.com/calendar/v3/calendars/" + (widget.lang.value ? en : fr) +"/events/?key=AIzaSyA9oGfxEwtmM7t5xlnCYjuuy5polbueWnI&timeMin=2018-08-01T15%3A19%3A21%2B00%3A00&timeMax=2019-06-30T15%3A19%3A21%2B00%3A00";
                print(url);
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


  Future<List<ImportDate>> _getImportedDates() async {
    List<ImportDate> dates = new List<ImportDate>();

    // if(saveDates != null) {
    //   return saveDates;
    // }

    final response = await get(url);

    if(response.statusCode == 200) {
      var jsonDates = json.decode(response.body);
      for(var date in jsonDates['items']) {
        dates.add(ImportDate.fromJson(date));
      }
    } else {
      throw Exception('Failed to load post');
    }


    saveDates = dates;

    return dates;

  }


  Widget _createListView(List<ImportDate> dates, BuildContext scaffoldContext) {

    return new ListView.builder(
      itemCount: dates.length,
      itemBuilder: (BuildContext context, int index) {
        ImportDate date = dates[index];
        return new Column(
          children: <Widget>[
            new ListTile(
              title: new Text(date.name, style: AppTextStyle.subPrimary),
              subtitle: new Text(TimeFormat.toImportantDate(date.start, date.end)),
              trailing: new IconButton(
                icon: new Icon(Icons.add), 
                tooltip: 'Add date', 
                onPressed: () async {
                    final eventToCreate = new Event(_selectedCalendar.id);
                    eventToCreate.title = date.name;
                    eventToCreate.start = date.start;
                    eventToCreate.end = date.end;
                    final createEventResult = await _deviceCalendarPlugin
                        .createOrUpdateEvent(eventToCreate);
                    if (createEventResult.isSuccess &&
                        (createEventResult.data?.isNotEmpty ?? false)) {
                      Scaffold.of(scaffoldContext).showSnackBar(new SnackBar(content: Text("Important Date Added To Calendar"),));
                    }
                }, 
              ),
            ),
            new Divider(),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    if(debugVal.value) {
      return Scaffold(
        appBar: AppBar(
          // leading: new Icon(Icons.star),
          // leading: new Icon(Icons.menu),
          title: Text((widget.lang.value ? 'Important Dates' : 'Dates Importantes')),
          centerTitle: false,
          actions: <Widget>[
            // new IconButton(
            //   icon: Icon(Icons.swap_calls),
            //   onPressed: () {
            //     if(debugVal.value){
            //       debugVal.value = false;
            //     } else {
            //       debugVal.value = true;
            //     }
            //   },
            // ),
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
        body: new FutureBuilder(
          future: _getImportedDates(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none: return new Text('Error');
              case ConnectionState.waiting: return new Center(child: new CircularProgressIndicator(),);
              default:
                if(snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                } else {
                  return _createListView(snapshot.data, context);
                }
            }
          
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: new Icon(Icons.star),
          title: Text((widget.lang.value ? 'Important Dates' : 'Dates Importantes')),
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
        body: new FutureBuilder(
          future: _getImportedDates(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.none: return new Text('Error');
              case ConnectionState.waiting: return new Center(child: new CircularProgressIndicator(),);
              default:
                if(snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                } else {
                  return _createListView(snapshot.data, context);
                }
            }
          
          },
        ),
      );
    }
  }
}



