// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/scheduler.dart';

import 'non_working_time.dart';
import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../components/event_scroll_notifier.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';

const int minutesADay = 1440;

/// Defines a single day page.
class InternalDayViewPage<T extends Object?> extends StatefulWidget {
  /// Width of the page
  final double width;

  /// Height of the page.
  final double height;

  /// Date for which we are displaying page.
  final DateTime date;

  /// A builder that returns a widget to show event on screen.
  final EventTileBuilder<T> eventTileBuilder;

  /// Controller for calendar
  final EventController<T> controller;

  /// A builder that builds time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Builds custom PressDetector widget
  final DetectorBuilder dayDetectorBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Custom painter for hour line.
  final CustomHourLinePainter hourLinePainter;

  /// Flag to display live time indicator.
  /// If true then indicator will be displayed else not.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings liveTimeIndicatorSettings;

  /// Height occupied by one minute of time span.
  final double heightPerMinute;

  /// Width of time line.
  final double timeLineWidth;

  /// Offset for time line widgets.
  final double timeLineOffset;

  /// Height occupied by one hour of time span.
  final double hourHeight;

  /// event arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line.
  final bool showVerticalLine;

  /// Offset  of vertical line.
  final double verticalLineOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Notifies if there is any event that needs to be visible instantly.
  final EventScrollConfiguration scrollNotifier;

  /// Display full day events.
  final FullDayEventBuilder<T> fullDayEventBuilder;

  /// Flag to display half hours.
  final bool showHalfHours;

  /// Flag to display quarter hours.
  final bool showQuarterHours;

  /// Settings for half hour indicator lines.
  final HourIndicatorSettings halfHourIndicatorSettings;

  /// First hour displayed in the layout
  final int startHour;

  /// Settings for half hour indicator lines.
  final HourIndicatorSettings quarterHourIndicatorSettings;

  /// Emulate vertical line offset from hour line starts.
  final double emulateVerticalOffsetBy;

  /// Defines extra top offset
  final double? topOffset;

  /// Defines extra bottom offset
  final double? bottomOffset;

  final List<NonWorkingTime> nonWorkingTimes;

  final Widget? nonWorkingContainer;

  /// Defines a single day page.
  const InternalDayViewPage(
      {Key? key,
      required this.showVerticalLine,
      required this.width,
      required this.date,
      required this.eventTileBuilder,
      required this.controller,
      required this.timeLineBuilder,
      required this.hourIndicatorSettings,
      required this.hourLinePainter,
      required this.showLiveLine,
      required this.liveTimeIndicatorSettings,
      required this.heightPerMinute,
      required this.timeLineWidth,
      required this.timeLineOffset,
      required this.height,
      required this.hourHeight,
      required this.eventArranger,
      required this.verticalLineOffset,
      required this.onTileTap,
      required this.onDateLongPress,
      required this.onDateTap,
      required this.minuteSlotSize,
      required this.scrollNotifier,
      required this.fullDayEventBuilder,
      required this.dayDetectorBuilder,
      required this.showHalfHours,
      required this.showQuarterHours,
      required this.halfHourIndicatorSettings,
      required this.startHour,
      required this.quarterHourIndicatorSettings,
      required this.emulateVerticalOffsetBy,
      this.topOffset,
      this.bottomOffset,
      this.nonWorkingTimes = const [],
      this.nonWorkingContainer})
      : super(key: key);

  @override
  State<InternalDayViewPage<T>> createState() => _InternalDayViewPageState<T>();
}

class _InternalDayViewPageState<T extends Object?>
    extends State<InternalDayViewPage<T>> {
  Timer? _timer;
  ScrollController? _scrollController;

  @override
  void initState() {
    // Auto scroll to current time after building widget
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentTime();

      // Auto scroll to current time after every minute
      _timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => scrollToCurrentTime(),
      );
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // Pre-setting approximate position of current time.
    // This will help auto scroll to current time faster and slightly
    _scrollController = ScrollController(
      initialScrollOffset: currentTimePosition,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final fullDayEventList = widget.controller.getFullDayEvent(widget.date);
    return Container(
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          fullDayEventList.isEmpty
              ? SizedBox.shrink()
              : widget.fullDayEventBuilder(fullDayEventList, widget.date),
          if (widget.topOffset != null)
            SizedBox.fromSize(
              size: Size.fromHeight(widget.topOffset!),
            ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: HourLinePainter(
                          lineColor: widget.hourIndicatorSettings.color,
                          lineHeight: widget.hourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.hourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          verticalLineOffset: widget.verticalLineOffset,
                          showVerticalLine: widget.showVerticalLine,
                          lineStyle: widget.hourIndicatorSettings.lineStyle,
                          dashWidth: widget.hourIndicatorSettings.dashWidth,
                          dashSpaceWidth:
                              widget.hourIndicatorSettings.dashSpaceWidth,
                          emulateVerticalOffsetBy:
                              widget.emulateVerticalOffsetBy,
                          startHour: widget.startHour),
                    ),
                    if (widget.showHalfHours)
                      CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: HalfHourLinePainter(
                          lineColor: widget.halfHourIndicatorSettings.color,
                          lineHeight: widget.halfHourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.halfHourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          lineStyle: widget.halfHourIndicatorSettings.lineStyle,
                          dashWidth: widget.halfHourIndicatorSettings.dashWidth,
                          dashSpaceWidth:
                              widget.halfHourIndicatorSettings.dashSpaceWidth,
                          startHour: widget.startHour,
                        ),
                      ),
                    if (widget.showQuarterHours)
                      CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: QuarterHourLinePainter(
                          lineColor: widget.quarterHourIndicatorSettings.color,
                          lineHeight:
                              widget.quarterHourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.quarterHourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          lineStyle:
                              widget.quarterHourIndicatorSettings.lineStyle,
                          dashWidth:
                              widget.quarterHourIndicatorSettings.dashWidth,
                          dashSpaceWidth: widget
                              .quarterHourIndicatorSettings.dashSpaceWidth,
                        ),
                      ),
                    widget.dayDetectorBuilder(
                      width: widget.width,
                      height: widget.height,
                      heightPerMinute: widget.heightPerMinute,
                      date: widget.date,
                      minuteSlotSize: widget.minuteSlotSize,
                    ),
                    if (widget.nonWorkingTimes.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: widget.height,
                          width: widget.width -
                              widget.timeLineWidth -
                              widget.hourIndicatorSettings.offset -
                              widget.verticalLineOffset,
                          child: Stack(
                              children: List.generate(
                            widget.nonWorkingTimes.length,
                            (i) {
                              final nonWorkingTime = widget.nonWorkingTimes[i];
                              final bottom = widget.height -
                                  (nonWorkingTime.endTime.getTotalMinutes -
                                                  (widget.startHour * 60) ==
                                              0
                                          ? minutesADay -
                                              (widget.startHour * 60)
                                          : nonWorkingTime
                                                  .endTime.getTotalMinutes -
                                              (widget.startHour * 60)) *
                                      widget.heightPerMinute;

                              final top =
                                  (nonWorkingTime.startTime.getTotalMinutes -
                                          (widget.startHour * 60)) *
                                      widget.heightPerMinute;
                              return Positioned(
                                top: top,
                                bottom: bottom,
                                left: 0,
                                right: 0,
                                child: widget.nonWorkingContainer ??
                                    const SizedBox(),
                              );
                            },
                          )),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: EventGenerator<T>(
                        height: widget.height,
                        date: widget.date,
                        onTileTap: widget.onTileTap,
                        eventArranger: widget.eventArranger,
                        events: widget.controller.getEventsOnDay(
                          widget.date,
                          includeFullDayEvents: false,
                        ),
                        heightPerMinute: widget.heightPerMinute,
                        eventTileBuilder: widget.eventTileBuilder,
                        scrollNotifier: widget.scrollNotifier,
                        startHour: widget.startHour,
                        width: widget.width -
                            widget.timeLineWidth -
                            widget.hourIndicatorSettings.offset -
                            widget.verticalLineOffset,
                      ),
                    ),
                    TimeLine(
                      height: widget.height,
                      hourHeight: widget.hourHeight,
                      timeLineBuilder: widget.timeLineBuilder,
                      timeLineOffset: widget.timeLineOffset,
                      timeLineWidth: widget.timeLineWidth,
                      showHalfHours: widget.showHalfHours,
                      startHour: widget.startHour,
                      showQuarterHours: widget.showQuarterHours,
                      key: ValueKey(widget.heightPerMinute),
                      liveTimeIndicatorSettings:
                          widget.liveTimeIndicatorSettings,
                    ),
                    if (widget.showLiveLine &&
                        widget.liveTimeIndicatorSettings.height > 0)
                      IgnorePointer(
                        child: LiveTimeIndicator(
                          liveTimeIndicatorSettings:
                              widget.liveTimeIndicatorSettings,
                          width: widget.width,
                          height: widget.height,
                          heightPerMinute: widget.heightPerMinute,
                          timeLineWidth: widget.timeLineWidth,
                          startHour: widget.startHour,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.bottomOffset != null)
            SizedBox.fromSize(
              size: Size.fromHeight(widget.bottomOffset!),
            ),
        ],
      ),
    );
  }

  void scrollToCurrentTime() => _scrollController?.jumpTo(currentTimePosition);

  double get hourHeight => widget.heightPerMinute * 60;

  double get currentTimePosition {
    final viewportDimension = _scrollController?.position.viewportDimension ??
        MediaQuery.of(context).size.height -
            (widget.topOffset ?? 0) -
            (widget.bottomOffset ?? 0);

    final currentTimeIndicatorPosition =
        (TimeOfDay.now().getTotalMinutes * widget.heightPerMinute) -
            (widget.startHour * hourHeight) -
            widget.liveTimeIndicatorSettings.topOffset;
    double scrollPixels =
        currentTimeIndicatorPosition - (viewportDimension / 2);

    final maxScrollExtent =
        hourHeight * (24 - widget.startHour) - viewportDimension;

    // Prevent scroll over max or min.
    if (scrollPixels > maxScrollExtent) {
      scrollPixels = maxScrollExtent;
    }
    if (scrollPixels < 0) {
      scrollPixels = 0;
    }

    return scrollPixels;
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _timer?.cancel();
    super.dispose();
  }
}

extension DateTimeExt on DateTime {
  int get getTotalMinutes => hour * 60 + minute;
}

extension TimerOfDayExtension on TimeOfDay {
  int get getTotalMinutes => hour * 60 + minute;
}
