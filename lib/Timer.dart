import 'dart:async';
import 'dart:isolate';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Isolate isolate;
Capability resumeCapability = new Capability();

void runTimer(SendPort sendPort) {
  int counter = 0;
  Timer.periodic(new Duration(seconds: 1), (Timer t) {
    counter++;
    int msg = counter;
    print('SEND: ' + msg.toString() + ' - ');
    sendPort.send(msg);
  });
}

class TimerWidget extends StatefulWidget {
  TimerWidget({Key key, this.minutes, this.seconds}) : super(key: key);

  final int minutes;
  final int seconds;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {
  int minutes = 0;
  int seconds = 0;
  int time = 0;

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
    print('dring dring');
    setState(() {
      alarm = true;
    });
    playLocal();
  }

  void sendMessage(SendPort sendPort, Object msg) {
    print('SEND: ' + msg.toString() + ' - ');
    sendPort.send(msg);
  }

  void start() async {
    ReceivePort receivePort= ReceivePort(); //port for this main isolate to receive messages.
    isolate = await Isolate.spawn(runTimer, receivePort.sendPort);
    resumeCapability = isolate.pauseCapability;

    receivePort.listen((data) {
      if (time <= 1) {
        setState(() {
          started = false;
          time = widget.minutes * 60 + widget.seconds;
        });

        runAlarm();
        stop();
        return;
      }

      setState(() {
        time--;
      });

      print('RECEIVE: ' + data.toString() + ', ');
      print('UPDATE TO: ' + time.toString() + ', ');
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(time.toString()),
        ElevatedButton(
          onPressed: () {
            handleTimer();
          },
          child: Text(started ? 'pause' : 'start'),
        ),
        alarm ? ElevatedButton(
          onPressed: () {
            stopMusic();
          },
          child: Text('stop'),
        ) : Text('')
      ],
    );
  }
}
