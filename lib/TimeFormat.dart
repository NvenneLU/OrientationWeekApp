import "Route.dart";

class TimeFormat {
  static String toMonthDay(DateTime time) {
    return _getMonth(time.month) + " " + time.day.toString();
  }

  static String toWeekdayTime(DateTime s, DateTime e) {
    if(s.day == e.day) {
      return _getWeekday(s.weekday) + " " + _getEnglishTime(s) + " - " + _getEnglishTime(e);
    } else {
      return _getWeekday(s.weekday) + " " + _getEnglishTime(s) + " - " + _getWeekday(e.weekday) + " " + _getEnglishTime(e);
    }
    
  }

  static String toDividerTime(DateTime time) {
    return _getWeekday(time.weekday).toUpperCase() + ", " + toMonthDay(time) + " " + time.year.toString();
  }

  static String toImportantDate(DateTime s, DateTime e) {
    if(s.month == e.month) {
      if(s.day + 1 == e.day) {
        return s.day.toString() + " " + _getMonthFull(s.month) + " " + s.year.toString();
      } else {
        return s.day.toString() + " - " + e.day.toString() + " " + _getMonthFull(s.month) + " " + s.year.toString();
      }
    } else {
      return s.day.toString() + " " + _getMonth(s.month) + " - " + e.day.toString() + " " + _getMonth(e.month) + " " + e.year.toString();
    }
  }

  static String toAnnouncementTime(DateTime s) {
    return _getMonth(s.month) + " " + s.day.toString() + ", " + _getEnglishTime(s);
  }

  static String _getEnglishTime(DateTime s) {
    if(s.hour == 0) {
      return "12:00 AM";
    } else if(s.hour > 12) {
      return (s.hour - 12).toString() + ":" + (s.minute < 10 ? s.minute.toString() + "0" : s.minute.toString()) + " PM";
    } else {
      return s.hour.toString() + ":" + (s.minute < 10 ? s.minute.toString() + "0" : s.minute.toString()) +  " AM"; 
    }
  }

  static String _getMonth(int month) {
    final lang = getLang();
    switch(month) {
      case 1: return lang ? "JAN" : "JANV";
      case 2: return lang ? "FEB" : "FÉVR";
      case 3: return lang ? "MAR" : "MARS";
      case 4: return lang ? "APR" : "AVR";
      case 5: return lang ? "MAY" : "MAI";
      case 6: return lang ? "JUN" : "JUIN";
      case 7: return lang ? "JUL" : "JUIL";
      case 8: return lang ? "AUG" : "AOÛT";
      case 9: return lang ? "SEP" : "SEPT";
      case 10: return lang ? "OCT" : "OCT";
      case 11: return lang ? "NOV" : "NOV";
      case 12: return lang ? "DEC" : "DÉC";
      default: return null;
    }
  }

  static String _getMonthFull(int month) {
    final lang = getLang();
    switch(month) {
      case 1: return lang ? "January" : "Janvier";
      case 2: return lang ? "Ferbuary" : "Février";
      case 3: return lang ? "March" : "Mars";
      case 4: return lang ? "April" : "Avril";
      case 5: return lang ? "May" : "Mai";
      case 6: return lang ? "June" : "Juin";
      case 7: return lang ? "July" : "Juillet";
      case 8: return lang ? "August" : "Août";
      case 9: return lang ? "September" : "Septembre";
      case 10: return lang ? "October" : "Octobre";
      case 11: return lang ? "November" : "Novembre";
      case 12: return lang ? "December" : "Décembre";
      default: return null;
    }
  }

  static String _getWeekday(int weekday) {
    final lang = getLang();
    switch(weekday) {
      case 1: return lang ? "Mon" : "Lun";
      case 2: return lang ? "Tue" : "Mar";
      case 3: return lang ? "Wed" : "Mer";
      case 4: return lang ? "Thu" : "Jeu";
      case 5: return lang ? "Fri" : "Ven";
      case 6: return lang ? "Sat" : "Sam";
      case 7: return lang ? "Sun" : "Dim";
      default: return null;
    }
  }

  static DateTime parseDateTime(String time) {
    // var split = time.split(" ");
    // var newTime = split[1].split(".");
    // var parseTime = newTime[0] + ":" + newTime[1] + ":00Z";

    // return DateTime.parse(split[0] + " " + parseTime);

    return DateTime.parse(time).toUtc();
  }
}