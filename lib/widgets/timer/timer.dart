import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:the_pret_flutter/utils/localization/app_localization.dart';
import 'package:the_pret_flutter/utils/adaptive_font_size.dart';

import 'package:the_pret_flutter/main.dart';
import 'package:the_pret_flutter/widgets/timer/timer_view.dart';

Isolate isolate;
Capability resumeCapability = new Capability();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

SharedPreferences prefs;

class TeaTimer extends StatefulWidget {
  TeaTimer({
    Key key,
    this.cbAtEnd,
    this.startTimer,
    @required this.minutes,
    @required this.seconds,
    @required this.notifications,
  }) : super(key: key);

  final bool startTimer;

  final int minutes;
  final int seconds;
  final Function cbAtEnd;
  final FlutterLocalNotificationsPlugin notifications;

  @override
  TimerController createState() => TimerController();
}

class TimerController extends State<TeaTimer> with WidgetsBindingObserver {
int minutes = 0;
  int seconds = 0;
  int time = 0;
  int timerId;

  double percentage = 0.0;

  bool started = false;
  bool alarm = false;

  AudioCache player = AudioCache();
  AudioPlayer audioPlayer;

  final String isolateName = 'isolate';


  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    minutes = widget.minutes;
    seconds = widget.seconds;
    time = widget.minutes * 60 + widget.seconds;

    if (widget.startTimer) {
      toggleTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance.removeObserver(this);
    stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {

    case AppLifecycleState.inactive:
      break;

    case AppLifecycleState.resumed:
      final prefs = await SharedPreferences.getInstance();
      prefs.reload();
      int alarmTime = prefs.getInt('alarm-time');
      int duration = DateTime.fromMillisecondsSinceEpoch(alarmTime, isUtc: true).difference(DateTime.now()).inSeconds;

      if (!started) {
        return;
      }

      if (duration > 0) {
        int startTime = widget.minutes * 60 + widget.seconds;

        setState(() {
          time = duration;
          percentage = 1 - (time / startTime);
        });
      } else {
        _cancelNotification();

        setState(() {
          started = false;
          time = 0;
          percentage = 1;
        });

        stop();

        if (!alarm) {
          runAlarm();
        }
      }
      break;

    case AppLifecycleState.paused:
      break;

    case AppLifecycleState.detached:
      break;
    }
  }

  Future<void> _cancelNotification() async {
    print('cancel notification');
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> fullScreenNotification() async {
    print('start notification');
    const int insistentFlag = 4;
    final prefs = await SharedPreferences.getInstance();

    prefs.reload();
    int alarmTime = prefs.getInt('alarm-time');
    int duration = DateTime.fromMillisecondsSinceEpoch(alarmTime, isUtc: true).difference(DateTime.now()).inSeconds;

    await widget.notifications.zonedSchedule(
      0,
      AppLocalizations.of(context).translate('timesupTitle'),
      AppLocalizations.of(context).translate('timesupBody'),
      tz.TZDateTime.now(tz.local).add(Duration(seconds: duration)),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'timesup',
          'notify when time is up',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          additionalFlags: Int32List.fromList(<int>[insistentFlag]),
          fullScreenIntent: true,
          playSound: false,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  void handleTimer() async {
    if (started == false && time > 0) {
      setState(() {
        started = true;
      });


      if (time < widget.minutes * 60 + widget.seconds) {
        resume();
      } else {
        await start();
        fullScreenNotification();
      }
    } else {
      setState(() {
        started = false;
      });

      pause();
    }
  }

  void runAlarm() {
    setState(() {
      alarm = true;
    });
    playLocal();
  }

  static void runTimer(SendPort sendPort) {
    int counter = 0;
    Timer.periodic(new Duration(seconds: 1), (Timer t) {
      counter++;
      int msg = counter;
      sendPort.send(msg);
    });
  }

  Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current-time', time);
    await prefs.setInt('alarm-time', DateTime.now().add(Duration(minutes:  minutes, seconds: seconds)).millisecondsSinceEpoch);

    ReceivePort receivePort = ReceivePort(); //port for this main isolate to receive messages.
    isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
    resumeCapability = isolate.pauseCapability;

    receivePort.listen((data) async {
      int startTime = widget.minutes * 60 + widget.seconds;

      if (time <= 0) {
        setState(() {
          started = false;
        });

        if (!alarm) {
          runAlarm();
        }
        stop();
        return;
      }

      setState(() {
        time--;
        percentage = 1 - (time / startTime);
      });

      await prefs.setInt('current-time', time);
    });
  }

  void stop() {
    _cancelNotification();

    if (isolate != null) {
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
    }
  }

  void pause() {
    _cancelNotification();

    if (isolate != null) {
      isolate.pause(resumeCapability);
    }
  }

  void resume() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alarm-time', DateTime.now().add(Duration(seconds: time)).millisecondsSinceEpoch);

    fullScreenNotification();

    if (isolate != null) {
      isolate.resume(resumeCapability);
    }
  }

  playLocal() async {
    if (audioPlayer != null) {
      return;
    }

    AudioPlayer ap = await player.loop('fini.mp3');

    setState(() {
      audioPlayer = ap;
    });
  }

  stopMusic() async {
    await audioPlayer.stop();

    player.clear('fini.mp3');

    setState(() {
      alarm = false;
      time = widget.minutes * 60 + widget.seconds;
      percentage = 0.0;
      audioPlayer = null;
    });
  }

  Icon displayIcon() {
    if (alarm) {
      return Icon(Icons.stop);
    }

    if (!started) {
      return Icon(Icons.play_arrow);
    }

    return Icon(Icons.pause);
  }

  List<Widget> displayTime(BuildContext context) {
    int min = (time ~/ 60);
    int sec = time % 60;

    List<Widget> texts = [];
    TextStyle style = TextStyle(fontSize: AdaptiveFontSize().getadaptiveTextSize(context, 90), fontWeight: FontWeight.bold);

    texts.addAll([
      Text((min).toString(), style: style),
      Text(':', style: style),
      Text((sec).toString().padLeft(2, '0'), style: style),
    ]);

    return texts;
  }

  void toggleTimer() {
    if (alarm) {
      stopMusic();
      widget?.cbAtEnd();
    } else {
      handleTimer();
    }
  }

  @override
  Widget build(BuildContext context) => TimerView(this);
}
