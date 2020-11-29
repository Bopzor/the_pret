import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:the_pret_flutter/Timer.dart';

class TeaScreen extends StatelessWidget {
  TeaScreen({Key key, this.tea}) : super(key: key);

  final tea;

  EdgeInsets setPadding(context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return EdgeInsets.all(0);
    }

    return EdgeInsets.only(bottom: 60, top: 20, right: 20, left: 20);
  }

  SpeedDial buildSpeedDial(context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.amber,
          onTap: () {
            Navigator.pushNamed(context, '/edit/' + tea['id']);
          },
          label: 'Edit',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.amberAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.archive, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => print('SECOND CHILD'),
          label: 'Archive',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.delete, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () => print('THIRD CHILD'),
          label: 'Delete',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.redAccent,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tea['name'])),
      body: Center(
        child: Padding(
          padding: setPadding(context),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
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
                        minutes: tea['time']['minutes'],
                        seconds: tea['time']['seconds'],
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
              );
            },
          )
        ),
      ),
      floatingActionButton: buildSpeedDial(context),
    );
  }
}
