// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:rue_app/controllers/attendance_controller.dart';

/// Example event class.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

Future<Map<DateTime, List<Event>>> mapToEvent(String uid) async {
  var temp = await getAttendanceRecordByUid(uid);
  var map = {
    for (var item in temp.keys)
      item: List.generate((temp[item]!.length), (index) {
        Event event = Event(temp[item]![index].toString());
        return event;
      })
  };
  return map;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(2011, 1, 1);
final kLastDay = kToday;
