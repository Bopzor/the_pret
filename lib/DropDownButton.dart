import 'package:flutter/material.dart';

class DropDownButtonWidget extends StatefulWidget {
  DropDownButtonWidget({Key key, this.value, this.options, this.onChange}) : super(key: key);

  final String value;
  final List<String> options;
  final Function onChange;

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

class _DropDownButtonWidgetState extends State<DropDownButtonWidget> {
  String dropdownValue;

  @override
  void initState() {
    super.initState();
    setState(() {
      dropdownValue = widget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      iconSize: 16,
      elevation: 16,
      underline: Container(
        height: 1,
        color: Colors.grey,
      ),
      onChanged: widget.onChange,
      items: widget.options
        .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
    );
  }
}
