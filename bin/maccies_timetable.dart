import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:io' as io;

import 'package:ical/serializer.dart';



void main(List<String> arguments) {
  print('I would like to die :)');
  io.File ttFile = io.File("maccies_timetable_page/ess_notice_board.html");
  Document ttHtml = parse(ttFile.readAsStringSync());
  List<Element> ttElements = ttHtml.getElementsByClassName("schdnormal");

  RegExp timeExp = RegExp(r"(\d+:\d+)-(\d+:\d+)");
  RegExp dateExp = RegExp(r"(\d{4})(\d{2})(\d{2})");

  List<MacciesShift> macciesShifts = [];

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
  io.File calOut = io.File("out/shifts.ics");
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

