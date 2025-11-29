import 'dart:async';
import 'package:Bloomee/blocs/timer/timer_bloc.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:numberpicker/numberpicker.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int _currentHour = 0;
  int _currentMinute = 0;
  int _currentSecond = 0;
  StreamSubscription<TimerState>? _timerBlocSubscription;

  void parseDuration(int duration, int Function(int) hourCallback,
      int Function(int) minuteCallback, int Function(int) secondCallback) {
    final hours = (duration / 3600).floor();
    final minutes = (duration % 3600 / 60).floor();
    final seconds = duration % 60;

    hourCallback(hours);
    minuteCallback(minutes);
    secondCallback(seconds);
  }

  @override
  void initState() {
    _timerBlocSubscription = context.read<TimerBloc>().stream.listen((event) {
      if (event is TimerRunInProgress) {
        setState(() {
          parseDuration(event.duration, (p0) => _currentHour = p0,
              (p1) => _currentMinute = p1, (p2) => _currentSecond = p2);
        });
      } else if (event is TimerInitial || event is TimerRunComplete) {
        setState(() {
          _currentHour = 0;
          _currentMinute = 0;
          _currentSecond = 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timerBlocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Default_Theme.themeColor,
        foregroundColor: Default_Theme.primaryColor1,
        centerTitle: true,
        title: Text(
          'Sleep Timer',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: Center(
        child: BlocBuilder<TimerBloc, TimerState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: switch (state) {
                TimerInitial() => timerInitial(),
                TimerRunInProgress() => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 60, left: 15, right: 15),
                          child: Text(
                            "Preparing for a peaceful interlude in…",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                    color: Default_Theme.primaryColor2,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold)
                                .merge(Default_Theme.secondoryTextStyle),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            timerLabel(label: "Hours", time: _currentHour),
                            timerLabel(label: "Minutes", time: _currentMinute),
                            timerLabel(label: "Seconds", time: _currentSecond),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<TimerBloc>()
                                  .add(const TimerStopped());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Default_Theme.accentColor2,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    MingCute.stop_circle_fill,
                                    color: Default_Theme.primaryColor2,
                                    size: 40,
                                  ),
                                ),
                                Text(
                                  "Stop Timer",
                                  style: const TextStyle(
                                          color: Default_Theme.primaryColor2,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)
                                      .merge(Default_Theme.secondoryTextStyle),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                TimerRunPause() => Container(),
                TimerRunStopped() => timerInitial(),
                TimerRunComplete() => Center(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 60, left: 10, right: 10),
                        child: Text(
                          "The tunes have rested. Sweet Dreams 🥰.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Default_Theme.accentColor2,
                              fontSize: 40,
                              fontFamily: "Unageo",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<TimerBloc>().add(const TimerReset());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Default_Theme.accentColor2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Got it!",
                          style: const TextStyle(
                                  color: Default_Theme.primaryColor2,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)
                              .merge(Default_Theme.secondoryTextStyle),
                        ),
                      ),
                    ],
                  )),
                _ => const Center(child: CircularProgressIndicator())
              },
            );
          },
        ),
      ),
    );
  }

  Widget timerInitial() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 270,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hours",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                              color: Default_Theme.primaryColor2, fontSize: 25)
                          .merge(Default_Theme.secondoryTextStyleMedium)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: NumberPicker(
                        minValue: 0,
                        maxValue: 23,
                        itemHeight: 80,
                        zeroPad: true,
                        infiniteLoop: true,
                        value: _currentHour,
                        textStyle: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.7),
                                fontSize: 20)
                            .merge(Default_Theme.secondoryTextStyle),
                        selectedTextStyle: const TextStyle(
                                color: Default_Theme.primaryColor2,
                                fontSize: 40)
                            .merge(Default_Theme.secondoryTextStyleMedium),
                        // zeroPad: true,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Default_Theme.primaryColor2.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          // border: Border.all(color: Default_Theme.primaryColor2),
                        ),
                        onChanged: (int value) {
                          setState(() => _currentHour = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Minutes",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                              color: Default_Theme.primaryColor2, fontSize: 25)
                          .merge(Default_Theme.secondoryTextStyleMedium)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        itemHeight: 80,
                        zeroPad: true,
                        infiniteLoop: true,
                        value: _currentMinute,
                        textStyle: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.7),
                                fontSize: 20)
                            .merge(Default_Theme.secondoryTextStyle),
                        selectedTextStyle: const TextStyle(
                                color: Default_Theme.primaryColor2,
                                fontSize: 40)
                            .merge(Default_Theme.secondoryTextStyleMedium),
                        // zeroPad: true,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Default_Theme.primaryColor2.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          // border: Border.all(color: Default_Theme.primaryColor2),
                        ),
                        onChanged: (int value) {
                          setState(() => _currentMinute = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Seconds",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                              color: Default_Theme.primaryColor2, fontSize: 25)
                          .merge(Default_Theme.secondoryTextStyleMedium)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        itemHeight: 80,
                        zeroPad: true,
                        infiniteLoop: true,
                        value: _currentSecond,
                        textStyle: TextStyle(
                                color: Default_Theme.primaryColor2
                                    .withValues(alpha: 0.7),
                                fontSize: 20)
                            .merge(Default_Theme.secondoryTextStyle),
                        selectedTextStyle: const TextStyle(
                                color: Default_Theme.primaryColor2,
                                fontSize: 40)
                            .merge(Default_Theme.secondoryTextStyleMedium),
                        // zeroPad: true,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Default_Theme.primaryColor2.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          // border: Border.all(color: Default_Theme.primaryColor2),
                        ),
                        onChanged: (int value) {
                          setState(() => _currentSecond = value);
                        },
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Default_Theme.accentColor2,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              if (_currentHour != 0 ||
                  _currentMinute != 0 ||
                  _currentSecond != 0) {
                context.read<TimerBloc>().add(TimerStarted(
                    duration: (_currentHour * 3600) +
                        (_currentMinute * 60) +
                        _currentSecond));
              } else {
                SnackbarService.showMessage("Please set a time",
                    duration: const Duration(seconds: 1));
              }
            },
            child: Text(
              "Start Timer",
              style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)
                  .merge(Default_Theme.secondoryTextStyle),
            ),
          ),
        ),
      ],
    );
  }

  Widget timerLabel({required String label, required int time}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                      color: Default_Theme.primaryColor2, fontSize: 25)
                  .merge(Default_Theme.secondoryTextStyleMedium)),
          Container(
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Default_Theme.primaryColor2.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              // border: Border.all(color: Default_Theme.primaryColor2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(time.toString().padLeft(2, '0'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                          color: Default_Theme.primaryColor2, fontSize: 35)
                      .merge(Default_Theme.secondoryTextStyleMedium)),
            ),
          ),
        ],
      ),
    );
  }
}
