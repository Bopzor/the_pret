import 'package:flutter/material.dart';
import 'package:the_pret_flutter/Timer.dart';

class TeaScreen extends StatelessWidget {
  TeaScreen({Key key, this.tea}) : super(key: key);

  final tea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tea['name'])),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 60, top: 20, right: 20, left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 120,
                    ),
                    child: Center(
                      child: Text(
                        tea['name'],
                        style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          tea['brand'],
                          style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic, color: Colors.grey)
                        )
                      ],
                    ),
                  ),
                ],
              ),
              TimerWidget(
                minutes: int.parse(tea['time']['minutes']),
                seconds: int.parse(tea['time']['seconds'])
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: tea['temperature'],
                    style: TextStyle(fontSize: 60, color: Colors.black)
                  ),
                  WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(2, -18),
                      child: Text(
                        '°C',
                        textScaleFactor: 2,
                      ),
                    ),
                  )
                ]),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        tooltip: 'Add tea',
        child: Icon(Icons.add),
      ),
    );
  }
}
