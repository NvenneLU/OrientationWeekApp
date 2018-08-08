class TimeFormat {
  static String toMonthDay(DateTime time) {
    return _getMonth(time.month) + " " + time.day.toString();
  }

  static String toWeekdayTime(DateTime s, DateTime e) {
    return _getWeekday(s.weekday) + " " + _getEnglishTime(s) + " - " + _getEnglishTime(e);
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
    if(s.hour > 12) {
      return (s.hour - 12).toString() + ":" + (s.minute < 10 ? s.minute.toString() + "0" : s.minute.toString()) + " PM";
    } else {
      return s.hour.toString() + ":" + (s.minute < 10 ? s.minute.toString() + "0" : s.minute.toString()) +  " AM"; 
    }
  }

  static String _getMonth(int month) {
    switch(month) {
      case 1: return "JAN";
      case 2: return "FEB";
      case 3: return "MAR";
      case 4: return "APR";
      case 5: return "MAY";
      case 6: return "JUN";
      case 7: return "JUL";
      case 8: return "AUG";
      case 9: return "SEP";
      case 10: return "OCT";
      case 11: return "NOV";
      case 12: return "DEC";
      default: return null;
    }
  }

  static String _getMonthFull(int month) {
    switch(month) {
      case 1: return "January";
      case 2: return "Ferbuary";
      case 3: return "March";
      case 4: return "April";
      case 5: return "May";
      case 6: return "June";
      case 7: return "July";
      case 8: return "August";
      case 9: return "September";
      case 10: return "October";
      case 11: return "November";
      case 12: return "December";
      default: return null;
    }
  }

  static String _getWeekday(int weekday) {
    switch(weekday) {
      case 1: return "Mon";
      case 2: return "Tue";
      case 3: return "Wed";
      case 4: return "Thu";
      case 5: return "Fri";
      case 6: return "Sat";
      case 7: return "Sun";
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