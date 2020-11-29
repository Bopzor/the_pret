import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_pret_flutter/DropDownButton.dart';

import 'package:flutter/cupertino.dart';

class AddScreen extends StatefulWidget {
  AddScreen({Key key, this.title, this.saveTea}) : super(key: key);

  final String title;
  final Function saveTea;

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _tempController = TextEditingController();
  int _minutes = 3;
  int _seconds = 0;
  List<int> minutesOptions = [1, 2, 3, 4, 5, 6];
  List<int> secondsOptions = [0, 15, 30, 45];

  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  String buildId() {
    return _nameController.text.replaceAll(' ', '-').toLowerCase()
      + _brandController.text.replaceAll(' ', '-').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  style: TextStyle(fontSize: 30),
                  textCapitalization: TextCapitalization.words,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  style: TextStyle(fontSize: 30),
                  textCapitalization: TextCapitalization.words,
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                  ),
                ),
                Container(
                  width: 80,
                  child: TextFormField(
                    style: TextStyle(fontSize: 30),
                    textCapitalization: TextCapitalization.words,
                    controller: _tempController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [LengthLimitingTextInputFormatter(3)],
                    decoration: InputDecoration(
                      labelText: 'Temp',
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
                      Text('Time', style: TextStyle(fontSize: 30, color: Colors.grey[700])),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(initialItem: 2),
                              itemExtent: 50, //height of each item
                              looping: true,
                              onSelectedItemChanged: (int index) {
                              },
                              children: <Widget>[
                                ...minutesOptions.map((options) {
                                  return (
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [Text(options.toString(), style: TextStyle(fontSize: 30))],
                                    )
                                  );
                              })],
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(maxWidth: 100),
                            child: CupertinoPicker(
                              scrollController: FixedExtentScrollController(initialItem: 0),
                              itemExtent: 50, //height of each item
                              looping: true,
                              onSelectedItemChanged: (int index) {
                              },
                              children: <Widget>[
                                ...secondsOptions.map((options) {
                                  return (
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [Text(options.toString().padLeft(2, '0'), style: TextStyle(fontSize: 30))],
                                    )
                                  );
                              })],
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
                        width: 100,
                        child:ElevatedButton(
                          onPressed: () {
                            Map<String, dynamic> tea = {
                              'id': buildId(),
                              'name': _nameController.text,
                              'brand': _brandController.text,
                              'temperature': _tempController.text,
                              'time': {
                                'minutes': _minutes,
                                'seconds': _seconds,
                              },
                              'count': 0,
                            };
                            widget.saveTea(tea);
                          },
                          child: Text('Save', style: TextStyle(fontSize: 30)),
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
  }
}
