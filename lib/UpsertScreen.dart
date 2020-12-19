import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:the_pret_flutter/app_localization.dart';
import 'package:uuid/uuid.dart';

class UpsertScreen extends StatefulWidget {
  UpsertScreen({
    Key key,
    this.tea,
    @required this.saveTea,
  }) : super(key: key);

  final Map<String, dynamic> tea;
  final Function saveTea;

  @override
  _UpsertScreenState createState() => _UpsertScreenState();
}

class _UpsertScreenState extends State<UpsertScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _tempController = TextEditingController();
  int _minutes = 3;
  int _seconds = 0;
  List<int> minutesOptions = [1, 2, 3, 4, 5, 6];
  List<int> secondsOptions = [0, 15, 30, 45];
  bool isButtonDisabled = true;

  @override
  void initState() {
    super.initState();

    if (widget.tea != null) {
      setState(() {
        _nameController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['name']));
        _brandController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['brand']));
        _tempController = TextEditingController.fromValue(
            TextEditingValue(text: widget.tea['temperature']));
        _minutes = widget.tea['time']['minutes'];
        _seconds = widget.tea['time']['seconds'];
        isButtonDisabled = false;
      });
    }

    _nameController.addListener(() => checkEmptyInput());
    _brandController.addListener(() => checkEmptyInput());
    _tempController.addListener(() => checkEmptyInput());
  }

  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  void checkEmptyInput() {
    List<String> values = [
      _nameController.text,
      _brandController.text,
      _tempController.text,
      _minutes.toString(),
      _seconds.toString()
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

  void onSaveTea() {
    Map<String, dynamic> tea = {
      'id': Uuid().v4(),
      'name': _nameController.text,
      'brand': _brandController.text,
      'temperature': _tempController.text,
      'time': {
        'minutes': _minutes,
        'seconds': _seconds,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('title'))),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(fontSize: 30),
                      textCapitalization: TextCapitalization.sentences,
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('name'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 30),
                      textCapitalization: TextCapitalization.sentences,
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('brand'),
                      ),
                    ),
                    Container(
                      width: 80,
                      child: TextFormField(
                        style: TextStyle(fontSize: 30),
                        textCapitalization: TextCapitalization.sentences,
                        controller: _tempController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3)
                        ],
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('temp'),
                          suffixText: '°C',
                          isDense: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).translate('time'),
                              style: TextStyle(
                                  fontSize: 30, color: Colors.grey[700])),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: getInitialMinutes()),
                                  itemExtent: 50, //height of each item
                                  looping: true,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _minutes = minutesOptions[index];
                                    });
                                  },
                                  children: <Widget>[
                                    ...minutesOptions.map((options) {
                                      return (Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(options.toString(),
                                              style: TextStyle(fontSize: 30))
                                        ],
                                      ));
                                    })
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: getInitialSeconds()),
                                  itemExtent: 50, //height of each item
                                  looping: true,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _seconds = secondsOptions[index];
                                    });
                                  },
                                  children: <Widget>[
                                    ...secondsOptions.map((options) {
                                      return (Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              options
                                                  .toString()
                                                  .padLeft(2, '0'),
                                              style: TextStyle(fontSize: 30))
                                        ],
                                      ));
                                    })
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                              ),
                              onPressed: isButtonDisabled
                                  ? null
                                  : () {
                                      onSaveTea();
                                    },
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('save'),
                                  style: TextStyle(fontSize: 30)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
