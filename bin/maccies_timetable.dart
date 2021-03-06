import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:io' as io;

import 'package:ical/serializer.dart';

void main(List<String> arguments) {

  // Opening the file
  io.File ttFile = io.File(arguments[0]);
  Document ttHtml = parse(ttFile.readAsStringSync());

  // This class name is in all boxes with shift times
  List<Element> ttElements = ttHtml.getElementsByClassName("schdnormal");

  // Defining expressions for extracting the time and date
  RegExp timeExp = RegExp(r"(\d+:\d+)-(\d+:\d+)");
  RegExp dateExp = RegExp(r"(\d{4})(\d{2})(\d{2})");

  List<MacciesShift> macciesShifts = [];

  var firstDayMatch = dateExp.firstMatch(ttElements[0].id);
  int weekStarting = int.parse(firstDayMatch.group(0));

  for (var elem in ttElements) {
    if (elem.innerHtml.substring(6).trim().isEmpty) {
    } else {
      // Obtain date
      var dateMatches = dateExp.allMatches(elem.id);
      var dateMatch = dateMatches.elementAt(0);
      // Obtain time
      var ttMatches = timeExp.allMatches(elem.innerHtml.substring(6).trim());
      var timeMatch = ttMatches.elementAt(0);
      // Format date/time as a DateTime parsable String
      String startTime = dateMatch.group(1) + "-" + dateMatch.group(2) + "-" + dateMatch.group(3) + " " + timeMatch.group(1);
      String endTime = dateMatch.group(1) + "-" + dateMatch.group(2) + "-" + dateMatch.group(3) + " " + timeMatch.group(2);
      macciesShifts.add(new MacciesShift(DateTime.parse(startTime), DateTime.parse(endTime)));
    }
  }

  // Adding shifts to an ical file
  ICalendar shiftsCal = ICalendar();
  for (var shift in macciesShifts) {
    shiftsCal.addElement(
      IEvent(
        summary: "Work",
        start: shift.start,
        end: shift.end,
        location: "McDonald's Portsmouth Ocean Retail Park",
        status: IEventStatus.CONFIRMED,
      ) 
    );
  }
  io.File calOut = io.File("shifts${weekStarting}.ics");
  var file = calOut.writeAsStringSync(shiftsCal.serialize());
}

class MacciesShift {
  DateTime start;
  DateTime end;

  MacciesShift(DateTime start, DateTime end) {
    this.start = start;
    this.end = end;
  }
}

