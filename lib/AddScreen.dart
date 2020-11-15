import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddScreen extends StatefulWidget {
  AddScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _tempController = TextEditingController();
  final _minutesController = TextEditingController();
  final _secondsController = TextEditingController();

  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _tempController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
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
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      child: TextFormField(
                        controller: _tempController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(3)],
                        decoration: InputDecoration(
                          labelText: 'Temperature',
                          suffixText: '°C',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          child: TextFormField(
                            controller: _minutesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [LengthLimitingTextInputFormatter(2)],
                            decoration: InputDecoration(
                              labelText: 'min',
                              hintText: '3',
                              suffixText: ':',
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          child: TextFormField(
                            controller: _secondsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [LengthLimitingTextInputFormatter(2)],
                            decoration: InputDecoration(
                              labelText: 's',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      print('submit');
                    },
                    child: Text('Submit'),
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
