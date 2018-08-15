import 'package:flutter/material.dart';
import 'AppStyles.dart';
import 'dart:async';
import 'TimeFormat.dart';
import 'dart:core';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';
import 'Route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
SharedPreferences prefs;


class ScheduleScreen extends StatefulWidget {

  final LanguageCallback callback;
  final ValueNotifier<bool> lang;

  ScheduleScreen({this.callback, this.lang});


  @override
  _ScheduleState createState() => new _ScheduleState();



  
}


class _ScheduleState extends State<ScheduleScreen> {

  String url;
  ScrollController _controller;
  DateTime _filter;
  List<DateTime> _dates;
  SelectableDayPredicate _selectableDay;

  _ScheduleState() {
    _deviceCalendarPlugin = new DeviceCalendarPlugin();
    _dates = new List<DateTime>();
  }

  void _initPreds() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  initState() {
    super.initState();
    _initPreds();
    _controller = new ScrollController();
    _filter = null;
    _dates = new List<DateTime>();
    _selectableDay = ((day) {
      return _dates.contains(day);
    });
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

  DateTime _date = DateTime.now();
  

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: new DateTime(2017),
      lastDate: new DateTime(2019),
      selectableDayPredicate: _selectableDay,
      locale: (widget.lang.value ? Locale('en', 'US') : Locale('fr', 'CA')),
      
    );

    if(picked != null && picked != _date) {
      setState(() {
        _date = picked;

        _filter = _date;
      });
    }
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
      body: new Column(
        children: <Widget>[
          new Container(
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
                            Expanded(
                              child: Text(_filter == null ? (widget.lang.value ? "Select Date Filter" : "Choisir filtre pour date") : TimeFormat.toDividerTime(_date)),
                            ),
                            GestureDetector(
                              child: Icon(_filter == null ? Icons.event : Icons.cancel, color: Colors.grey[700],),
                              onTap: () {setState(() {
                                                              _filter = null;
                                                            });},
                            ) 
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
          ),
          new Expanded(
            child: new StreamBuilder(
              stream: Firestore.instance.collection("events" + (widget.lang.value ? 'E' : 'F')).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Center(child: CircularProgressIndicator());
                  var data = snapshot.data.documents.toList(growable: false);
                  List<Widget> info = new List<Widget>();
                  var sortedKeys = data
                  ..sort((k1, k2) => k1['startTime'].compareTo(k2['startTime']));
                  DateTime tempDate = sortedKeys[0]['startTime'];
                  if(_filter != null) {
                    info.add(_ScheduleDivider(_filter));
                    _dates.add(DateTime(_filter.year, _filter.month, _filter.day));
                    _date = DateTime(_filter.year, _filter.month, _filter.day);
                  } else {
                    info.add(_ScheduleDivider(tempDate));
                    _dates.add(DateTime(tempDate.year, tempDate.month, tempDate.day));
                    _date = DateTime(tempDate.year, tempDate.month, tempDate.day);
                  }
                  sortedKeys.forEach((dynamic v) {
                            if(_filter == null) {
                              if(tempDate.day != v['startTime'].day) {
                                tempDate = v['startTime'];
                                info.add(_ScheduleDivider(tempDate));
                                _dates.add(DateTime(tempDate.year, tempDate.month, tempDate.day));
                              }
                              info.add(ScheduleCard(event: v['name'], desc: v['desc'], attendee: v['attendee'], location: v['location'], endDate: v['endTime'], startDate: v['startTime'], id: v.documentID,));
                            } else if (_filter.day == v['startTime'].day && _filter.month == v['startTime'].month) {
                              info.add(ScheduleCard(event: v['name'], desc: v['desc'], attendee: v['attendee'], location: v['location'], endDate: v['endTime'], startDate: v['startTime'], id: v.documentID,));
                            }
                          });

                  return new ListView(
                    controller: _controller,
                    padding: EdgeInsets.only(top: 10.0),
                    children: info,
                  );
              }   
            ),
          )
        ],
      )
    );
  }
}



class ScheduleCard extends StatefulWidget {

  final String event;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String desc;
  final String attendee;
  final String id;
  

  ScheduleCard({this.event, this.desc, this.location, this.startDate, this.endDate, this.attendee, this.id});

  @override
  _ScheduleCardState createState() => new _ScheduleCardState();
  

}

class _ScheduleCardState extends State<ScheduleCard> {

  bool _selected;


  @override
  void initState() {
      // TODO: implement initState
      super.initState();

      this._selected = prefs.getBool(widget.event) ?? false;
    }

  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        new GestureDetector(
          onTap: () {
              Navigator.push(context, PageRouteBuilder(
              opaque: true,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (BuildContext context, _, __) {
                return Scaffold(
                  appBar: AppBar(
                    leading: Icon(Icons.event),
                    title: Text("View Event"),
                    centerTitle: false,
                  ),
                  body: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails e) {
                      if(e.velocity.pixelsPerSecond.dx > 1000) {
                        Navigator.of(context).pop();
                      }
                    },
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
                                    child: new Text(widget.event,
                                      overflow: TextOverflow.fade,
                                      style: AppTextStyle.h6,
                                    ),
                                  ),
                                  new Text(TimeFormat.toMonthDay(widget.startDate),
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
                                    child: new Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: new Text(widget.location,
                                        style: AppTextStyle.subMedEmp,
                                        overflow: TextOverflow.fade,
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                            new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                              child: new Row(
                                children: <Widget>[
                                  new Icon(Icons.access_time, color: Colors.grey[600],),
                                  new Expanded(
                                    child: new Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: new Text(TimeFormat.toWeekdayTime(widget.startDate, widget.endDate),
                                        style: AppTextStyle.subMedEmp,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            new Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 6.0),
                              child: new Row(
                                children: <Widget>[
                                  new Icon(Icons.people, color: Colors.grey[600],),
                                  new Expanded(
                                    child: new Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: new Text(widget.attendee,
                                        overflow: TextOverflow.clip,
                                        style: AppTextStyle.subMedEmp,
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ),
                            new Padding(
                              padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 14.0),
                              child: new Text(widget.desc,
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
                                      print(widget.startDate.timeZoneName);
                                      final eventToCreate = new Event(_selectedCalendar.id);
                                      eventToCreate.title = widget.event;
                                      eventToCreate.start = widget.startDate;
                                      eventToCreate.end = widget.endDate;
                                      eventToCreate.location = widget.location;
                                      eventToCreate.description = widget.desc;
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
                  ),
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
                          child: new Text(widget.event,
                            overflow: TextOverflow.fade,
                            style: AppTextStyle.h6,
                          ),
                        ),
                        new Text(TimeFormat.toMonthDay(widget.startDate),
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
                          child: new Text(' ' + widget.location,
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
                        new Text(' ' + TimeFormat.toWeekdayTime(widget.startDate, widget.endDate),
                          style: AppTextStyle.subMedEmp,
                        )
                      ],
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(4.0, 4.0, 40.0, 14.0),
                    child: new Text(widget.desc,
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
            heroTag: widget.id,
            child: Icon((this._selected ? Icons.check : Icons.add)),
            onPressed: () async {
                if(this._selected) {
                  Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Event already in calendar"),));
                  return;
                }
                final eventToCreate = new Event(_selectedCalendar.id);
                eventToCreate.title = widget.event;
                eventToCreate.start = widget.startDate;
                eventToCreate.end = widget.endDate;
                eventToCreate.location = widget.location;
                eventToCreate.description = widget.desc;
                final createEventResult = await _deviceCalendarPlugin
                    .createOrUpdateEvent(eventToCreate);
                if (createEventResult.isSuccess &&
                    (createEventResult.data?.isNotEmpty ?? false)) {
                  setState(() {
                                      this._selected = true;
                                      prefs.setBool(widget.event, true);
                                    });
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
