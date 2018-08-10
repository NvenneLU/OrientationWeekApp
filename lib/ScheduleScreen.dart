import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'AppStyles.dart';
import 'dart:async';
import 'TimeFormat.dart';
import 'dart:core';
import 'package:after_layout/after_layout.dart';
import 'dart:convert';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'Route.dart';

class ImportCards {
  final String event;
  final String desc;
  final String location;
  final String attendee;
  final DateTime startTime;
  final DateTime endTime;

  ImportCards({this.event, this.desc, this.location, this.attendee, this.startTime, this.endTime});

  factory ImportCards.fromJson(Map<String, dynamic> json) {
    return ImportCards(
      event: json['event'],
      desc: json['desc'],
      location: json['location'],
      attendee: json['attendee'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }
}

List<ImportCards> saveCards;
Map<DateTime, double> scrollPos = Map<DateTime, double>();
List<DateTime> scrollPosDate = List<DateTime>();
List<double> scrollPosVal = List<double>();
ScrollController globalScroll = new ScrollController();
double lastScroll = 0.0;
int lastIndex = 0;
BuildContext scaffoldContext;

DeviceCalendarPlugin _deviceCalendarPlugin;
Calendar _selectedCalendar;
List<Calendar> _calendars;


class ScheduleScreen extends StatefulWidget {

  final LanguageCallback callback;
  final ValueNotifier<bool> lang;

  ScheduleScreen({this.callback, this.lang});


  @override
  _ScheduleState createState() => new _ScheduleState();



  
}


class _ScheduleState extends State<ScheduleScreen> {

  String url;

  _ScheduleState() {
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
  }

  @override
  initState() {
    super.initState();
    url = 'https://www3.laurentian.ca/orientationWeekApp/getSchedule' + (widget.lang.value ? 'EN' : 'FR') + '.php';
    _retrieveCalendars();
    widget.lang.addListener(() {
      
      if(this.mounted) {
        String temp = widget.lang.value ? 'EN' : 'FR';
        setState(() {
                url = 'https://www3.laurentian.ca/orientationWeekApp/getSchedule' + temp + '.php';
                lastScroll = 0.0;
                lastIndex = 0;
              });
      }
    });
    
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


  Future<List<ImportCards>> _getImportedCards() async {

    List<ImportCards> cards = new List<ImportCards>();

    // if(saveCards != null) { 
    //   return saveCards;
    // }

    final response = await get(url);

    if(response.statusCode == 200) {
      var jsonCards = json.decode(response.body);
      for(var card in jsonCards) {
        cards.add(ImportCards.fromJson(card));
      }
    } else {
      throw Exception('Failed to load post');
    }

    saveCards = cards;

    return cards;
  }

  DateTime lastDate = DateTime(1970);


  @override
  Widget build(BuildContext context) {

    scaffoldContext = context;

    return Scaffold(
      appBar: AppBar(
        leading: new Icon(Icons.event),
        // leading: new Icon(Icons.menu),
        title: Text((widget.lang.value ? 'Schedule' : 'Programme')),
        centerTitle: false,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.language),
            tooltip: 'Language',
            onPressed: () {
              if(widget.lang.value) {
                widget.callback(false);
              } else {
                widget.callback(true);
              }
            },
          )
        ],
      ),
      body: new FutureBuilder(
        future: _getImportedCards(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none: return new Text('Error');
            case ConnectionState.waiting: return new Center(child: new CircularProgressIndicator());
            default:
              if(snapshot.hasError) {
                return Text('Error ${snapshot.error}');
              } else {
                return new CustomListView(cards: snapshot.data,);
              }
          }
        },
      )
    );
  }
}

class CustomListView extends StatefulWidget {
  const CustomListView({ Key key, this.cards}) : super(key: key);

  final List<ImportCards> cards;

  @override
  _CustomListViewState createState() => new _CustomListViewState(cards: cards,);
}



class _CustomListViewState extends State<CustomListView> with AfterLayoutMixin<CustomListView>{

  final List<ImportCards> cards;
  static SchedulePicker _picker;
  GlobalKey<_SchedulePickerState> _key;
  int _index = lastIndex;
  bool init = false;


  _CustomListViewState({this.cards}) {
    _key = new GlobalKey<_SchedulePickerState>();
    DateTime start;
    if(scrollPosDate.length > 0) {
      start = scrollPosDate[lastIndex];
    } else {
      start = saveCards[0].startTime.subtract(new Duration(hours: saveCards[0].startTime.hour, minutes: saveCards[0].startTime.minute));
    }
    _index = lastIndex;
    _picker = new SchedulePicker(key: _key, startDate: start);
    
    
  }

  void listen() {
    if(this.mounted) {
      
      var pos = globalScroll.position.pixels;
      // lastScroll = pos;
      if(scrollPosVal.length > (_index + 1)) {
        if(pos > scrollPosVal[_index + 1]) {
          if(_key.currentState == null)
            return;
          _index = _index + 1;
          // lastIndex = _index;
          
          _key.currentState.changeDate(scrollPosDate[_index]);
          
        }
      }
      if(pos < scrollPosVal[_index]) {
        if(_index == 0)
          return;
          if(_key.currentState == null)
            return;
        _index = _index - 1;
        // lastIndex = _index;
        _key.currentState.changeDate(scrollPosDate[_index]);
      }
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
   globalScroll.jumpTo(lastScroll);
   globalScroll.addListener(listen);
  }
  

  @override
  Widget build(BuildContext context) {
    scrollPosDate.clear();
    scrollPosVal.clear();
    var lastDate = DateTime(1970);
    int count = 0;

    return new Column(
      children: <Widget>[
        _picker,
        new Expanded(
          child: new ListView.builder(
            controller: globalScroll,
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              ImportCards card = cards[index];
              if(card.startTime.day > lastDate.day) {
                lastDate = card.startTime;
                
                scrollPosDate.add(card.startTime.subtract(new Duration(hours: card.startTime.hour, minutes: card.startTime.minute)));
                scrollPosVal.add((index * 237.0) + (count * 34));
                count++;
                return new Column(
                  children: <Widget>[
                    new _ScheduleDivider(card.startTime),
                    new ScheduleCard(
                      event: card.event,
                      desc: card.desc,
                      location: card.location,
                      startDate: card.startTime,
                      endDate: card.endTime,
                      id: index,
                    ),
                  ],
                );
              } else {
                return new ScheduleCard(
                  event: card.event,
                  desc: card.desc,
                  location: card.location,
                  startDate: card.startTime,
                  endDate: card.endTime,
                  id: index,
                );
              }
            }
          ),
        )
      ],
    );
  }
}




class ScheduleCard extends StatelessWidget {

  final String event;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String desc;
  final int id;

  ScheduleCard({this.event, this.desc, this.location, this.startDate, this.endDate, this.id});

  void _openEventView(int id, BuildContext context) {
    if(saveCards == null)
      return;

    lastScroll = globalScroll.position.pixels;
    Navigator.push(context, PageRouteBuilder(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext context, _, __) {
        return new EventView(id: id);
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

  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onTap: () {_openEventView(this.id, context);},
          child: new Card(
            margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 25.0),
            child: new Container(
              padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Expanded(
                          child: new Text(this.event,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.h6,
                          ),
                        ),
                        new Text(TimeFormat.toMonthDay(this.startDate),
                          style: AppTextStyle.ovlnMedEmp,
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.location_on, color: Colors.grey[600],),
                        new Expanded(
                          child: new Text(' ' + this.location,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.subMedEmp,
                          ),
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                    child: new Row(
                      children: <Widget>[
                        new Icon(Icons.access_time, color: Colors.grey[600],),
                        new Text(' ' + TimeFormat.toWeekdayTime(this.startDate, this.endDate),
                          style: AppTextStyle.subMedEmp,
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 40.0, 14.0),
                    child: new Text(this.desc,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: AppTextStyle.bodyMedEmp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        new Positioned(
          bottom: 6.0,
          right: 30.0,
          child: new FloatingActionButton(
            heroTag: "card" + this.id.toString(),
            child: const Icon(Icons.add),
            onPressed: () async {
                print(this.startDate.timeZoneName);
                final eventToCreate = new Event(_selectedCalendar.id);
                eventToCreate.title = this.event;
                eventToCreate.start = this.startDate;
                eventToCreate.end = this.endDate;
                eventToCreate.location = this.location;
                eventToCreate.description = this.desc;
                final createEventResult = await _deviceCalendarPlugin
                    .createOrUpdateEvent(eventToCreate);
                if (createEventResult.isSuccess &&
                    (createEventResult.data?.isNotEmpty ?? false)) {
                  Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Event Added To Calendar"),));
                }
            },
            mini: true,
          ),
        )
      ],
    );
  }
}

class EventView extends StatelessWidget {

  final int id;

  EventView({this.id});

  @override
  Widget build(BuildContext context) {
    ImportCards card = saveCards[this.id];

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.event),
        title: Text("View Event"),
        centerTitle: false,
      ),
      body: new Card(
          margin: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 25.0),
          child: new Container(
            padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 8.0),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Expanded(
                        child: new Text(card.event,
                          overflow: TextOverflow.fade,
                          style: AppTextStyle.h6,
                        ),
                      ),
                      new Text(TimeFormat.toMonthDay(card.startTime),
                        style: AppTextStyle.ovlnMedEmp,
                      )
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
                  child: new Row(
                    children: <Widget>[
                      new Icon(Icons.location_on, color: Colors.grey[600],),
                      new Expanded(
                        child: new Text(' ' + card.location,
                          style: AppTextStyle.subMedEmp,
                        ),
                      )
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                  child: new Row(
                    children: <Widget>[
                      new Icon(Icons.access_time, color: Colors.grey[600],),
                      new Text(' ' + TimeFormat.toWeekdayTime(card.startTime, card.endTime),
                        style: AppTextStyle.subMedEmp,
                      )
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                  child: new Row(
                    children: <Widget>[
                      new Icon(Icons.people, color: Colors.grey[600],),
                      new Text(' ' + card.attendee,
                        style: AppTextStyle.subMedEmp,
                      )
                    ],
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 14.0),
                  child: new Text(card.desc,
                    style: AppTextStyle.bodyMedEmp,
                  ),
                ),
                new ButtonTheme.bar(
                  textTheme: ButtonTextTheme.primary,
                  child: ButtonBar(
                    alignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new OutlineButton( 
                        child: new Text("BACK", style: TextStyle(color: CompanyColors.blue),),
                        onPressed: () {Navigator.of(context).pop();},
                      ),
                      new OutlineButton( 
                        child: new Text("ADD TO CALENDAR", style: TextStyle(color: CompanyColors.blue),),
                        onPressed: () async {
                          print(card.startTime.timeZoneName);
                          final eventToCreate = new Event(_selectedCalendar.id);
                          eventToCreate.title = card.event;
                          eventToCreate.start = card.startTime;
                          eventToCreate.end = card.endTime;
                          eventToCreate.location = card.location;
                          eventToCreate.description = card.desc;
                          final createEventResult = await _deviceCalendarPlugin
                              .createOrUpdateEvent(eventToCreate);
                          if (createEventResult.isSuccess &&
                              (createEventResult.data?.isNotEmpty ?? false)) {
                            Scaffold.of(scaffoldContext).showSnackBar(new SnackBar(content: Text("Event Added To Calendar"),));
                          }
                      }, 
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
    );
  }

}

class _ScheduleDivider extends StatelessWidget {

  final DateTime date;

  _ScheduleDivider(this.date);

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: EdgeInsets.fromLTRB(15.0, 12.0, 15.0, 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(TimeFormat.toDividerTime(date),
            style: AppTextStyle.ovlnAccCol,
            textAlign: TextAlign.start,
          ),
          new Divider(),
        ],
      ),
    );
  }
}

class SchedulePicker extends StatefulWidget {
  const SchedulePicker({ Key key, this.startDate}) : super(key: key);

  final DateTime startDate;

  @override
  _SchedulePickerState createState() => new _SchedulePickerState();
}

class _SchedulePickerState extends State<SchedulePicker> {

  DateTime _date = DateTime.now();
  bool _init = false;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2017),
      lastDate: new DateTime(2019),
    );

    if(picked != null && picked != _date) {
      setState(() {
        _date = picked;

        var temp = _date.subtract(new Duration(hours: _date.hour, minutes: _date.minute));
        var index = scrollPosDate.indexOf(temp);
        print(temp);
        if(index == -1) {
          return;
        }
        globalScroll.animateTo(scrollPosVal.elementAt(index) + 4, duration: new Duration(seconds: 1), curve:  Curves.ease);
        
      });
    }
  }

  void changeDate(DateTime date) {
    setState(() {
          _date = date;
        });
  }




  @override
  Widget build(BuildContext context) {
    if(!_init) {
      _date = widget.startDate;
      _init = true;
    }
    
    return new Container(
      padding: EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 0.0),
      child: new Row( 
        children: <Widget>[
          new Expanded(
            child: new GestureDetector(
              child: new DecoratedBox(
                child: new Container(
                  padding: EdgeInsets.all(14.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                    Text(TimeFormat.toDividerTime(_date)),
                    Icon(Icons.event, color: Colors.grey[700],),
                  ],),
                ),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  border: new Border.all(
                    color: CompanyColors.blue,
                    width: 2.0
                  )
                ),
              ),
              onTap: () {_selectDate(context);},
            )
          ),
        ],
      ),
    );
  }
}
