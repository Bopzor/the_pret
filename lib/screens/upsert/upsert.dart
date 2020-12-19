import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:the_pret_flutter/screens/upsert/upsert_view.dart';

class UpsertScreen extends StatefulWidget {
  UpsertScreen({
    Key key,
    this.tea,
    @required this.saveTea,
  }) : super(key: key);

  final Map<String, dynamic> tea;
  final Function saveTea;

  @override
  UpsertController createState() => UpsertController();
}

class UpsertController extends State<UpsertScreen> {
TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  int minutes = 3;
  int seconds = 0;
  List<int> minutesOptions = [1, 2, 3, 4, 5, 6];
  List<int> secondsOptions = [0, 15, 30, 45];
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();

    if (widget.tea != null) {
      setState(() {
        nameController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['name']));
        brandController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['brand']));
        tempController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['temperature']));
        minutes = widget.tea['time']['minutes'];
        seconds = widget.tea['time']['seconds'];
        isButtonDisabled = false;
      });
    }

    nameController.addListener(() => checkEmptyInput());
    brandController.addListener(() => checkEmptyInput());
    tempController.addListener(() => checkEmptyInput());
  }

  void dispose() {
    nameController.dispose();
    brandController.dispose();
    tempController.dispose();
    super.dispose();
  }

  void checkEmptyInput() {
    List<String> values = [
      nameController.text,
      brandController.text,
      tempController.text,
      minutes.toString(),
      seconds.toString()
    ];

    if (values.any((element) => element.isEmpty)) {
      setState(() => isButtonDisabled = true);
    } else {
      setState(() => isButtonDisabled = false);
    }
  }

  int getInitialMinutes() {
    if (widget.tea != null) {
      return minutesOptions.indexOf(widget.tea['time']['minutes']);
    }

    return 2;
  }

  int getInitialSeconds() {
    if (widget.tea != null) {
      return secondsOptions.indexOf(widget.tea['time']['seconds']);
    }

    return 0;
  }

  void onMinutesChange(int index) {
    setState(() {
      minutes = minutesOptions[index];
    });
  }

  void onSecondsChange(int index) {
    setState(() {
      seconds = secondsOptions[index];
    });
  }

  void onSaveTea() {
    Map<String, dynamic> tea = {
      'id': Uuid().v4(),
      'name': nameController.text,
      'brand': brandController.text,
      'temperature': tempController.text,
      'time': {
        'minutes': minutes,
        'seconds': seconds,
      },
      'count': 0,
      'archived': false,
    };

    if (widget.tea != null) {
      tea['id'] = widget.tea['id'];
      tea['archived'] = widget.tea['archived'];
    }

    widget.saveTea(tea);

    if (widget.tea != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/tea/' + widget.tea['id'],
        (Route<dynamic> route) => route.settings.name == '/',
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => UpsertView(this);
}
