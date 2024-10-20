import 'package:flutter/material.dart';

class TimeZoneUtils {
  static TimeOfDay getTimeOfDayInUserTimeZone(
      DateTime Function()? getNowInTimeZone) {
    if (getNowInTimeZone != null) {
      final nowInTimeZone = getNowInTimeZone.call();
      return TimeOfDay(
        hour: nowInTimeZone.hour,
        minute: nowInTimeZone.minute,
      );
    }
    return TimeOfDay.now();
  }
}
