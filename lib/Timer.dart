import 'dart:async';
import 'dart:isolate';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the_pret_flutter/adaptive_font_size.dart';

Isolate isolate;
Capability resumeCapability = new Capability();

void runTimer(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    counter++;
    int msg = counter;
    sendPort.send(msg);
  });
}

class TimerWidget extends StatefulWidget {
  TimerWidget({
    Key key,
    this.cbAtEnd,
    @required this.minutes,
    @required this.seconds,
  }) : super(key: key);

  final int minutes;
  final int seconds;
  final Function cbAtEnd;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {
  int minutes = 0;
  int seconds = 0;
  int time = 0;

  double percentage = 0.0;

  bool started = false;
  bool alarm = false;

  AudioCache player = AudioCache();
  AudioPlayer audioPlayer;

  void initState() {
    super.initState();

    setState(() {
      minutes = widget.minutes;
      seconds = widget.seconds;
      time = widget.minutes * 60 + widget.seconds;
    });
  }

  void handleTimer() {
    if (started == false) {
      setState(() {
        started = true;
      });

      if (time < widget.minutes * 60 + widget.seconds) {
        resume();
      } else {
        start();
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

  void sendMessage(SendPort sendPort, Object msg) {
    sendPort.send(msg);
  }

  void start() async {
    ReceivePort receivePort= ReceivePort(); //port for this main isolate to receive messages.
    isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
    resumeCapability = isolate.pauseCapability;

    receivePort.listen((data) {
      int startTime = widget.minutes * 60 + widget.seconds;

      if (time <= 0) {
        setState(() {
          started = false;
        });

        runAlarm();
        widget?.cbAtEnd();
        stop();
        return;
      }

      setState(() {
        time--;
        percentage = 1 - (time / startTime);
      });
    });
  }

  void stop() {
    if (isolate != null) {
      print('killing isolate');
      isolate.kill(priority: Isolate.immediate);
      isolate = null;
    }
  }

  void pause() {
    if (isolate != null) {
      print('pause isolate');
      isolate.pause(resumeCapability);
    }
  }

  void resume() {
    if (isolate != null) {
      print('resume isolate');
      isolate.resume(resumeCapability);
    }
  }

  playLocal() async {
    AudioPlayer ap = await player.loop('fini.mp3');

    setState(() {
      audioPlayer = ap;
    });
  }

  stopMusic() async {
    player.clear('fini.mp3');

    await audioPlayer.stop();

    setState(() {
      alarm = false;
      time = widget.minutes * 60 + widget.seconds;
      percentage = 0.0;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      constraints: BoxConstraints(
        minHeight: 100,
        minWidth: 100,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              constraints: BoxConstraints(
                minHeight: 100,
                minWidth: 100,
              ),
              child:
                CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Theme.of(context).backgroundColor,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                  strokeWidth: 15,
                ),
              ),
          ) ,

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [...displayTime(context)],
            ),
          ),

          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: IconButton(
                icon: displayIcon(),
                iconSize: AdaptiveFontSize().getadaptiveTextSize(context, 60.0),
                onPressed: () {
                  if (alarm) {
                    stopMusic();
                  } else {
                    handleTimer();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
