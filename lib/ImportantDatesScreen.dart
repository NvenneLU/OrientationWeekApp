import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'dart:convert';
import 'TimeFormat.dart';
import 'Route.dart';


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

  String fr = "laurentian.ca_7uqfoldfh55ml6gsvbvui7bdac@group.calendar.google.com";
  String en = "laurentian.ca_62rsj0ue19b2kflvsigkjrk4ac@group.calendar.google.com";
  String url;

  @override
  initState() {
    super.initState();

    url = "https://www.googleapis.com/calendar/v3/calendars/" + (widget.lang.value ? en : fr) +"/events/?key=AIzaSyA9oGfxEwtmM7t5xlnCYjuuy5polbueWnI&timeMin=2018-08-01T15%3A19%3A21%2B00%3A00&timeMax=2019-06-30T15%3A19%3A21%2B00%3A00";

    widget.lang.addListener(() {
      setState(() {
              url = "https://www.googleapis.com/calendar/v3/calendars/" + (widget.lang.value ? en : fr) +"/events/?key=AIzaSyA9oGfxEwtmM7t5xlnCYjuuy5polbueWnI&timeMin=2018-08-01T15%3A19%3A21%2B00%3A00&timeMax=2019-06-30T15%3A19%3A21%2B00%3A00";
              print(url);
            });
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


  Widget _createListView(List<ImportDate> dates) {

    return new ListView.builder(
      itemCount: dates.length,
      itemBuilder: (BuildContext context, int index) {
        ImportDate date = dates[index];
        return new Column(
          children: <Widget>[
            new _ImportantDate(date.name, TimeFormat.toImportantDate(date.start, date.end)),
            new Divider(),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.priority_high),
        title: Text('Important Dates'),
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
                return _createListView(snapshot.data);
              }
          }
        
        },
      ),
    );
  }
}





class _ImportantDate extends StatelessWidget {


  final String title;
  final String date;

  _ImportantDate(this.title, this.date);

  @override
  Widget build(BuildContext context) {  
    return new ListTile(
      title: new Text(this.title, style: AppTextStyle.subPrimary),
      subtitle: new Text(this.date),
      trailing: new IconButton(
        icon: new Icon(Icons.add), 
        tooltip: 'Add date', 
        onPressed: () {}, 
      ),
    );
  }
}

