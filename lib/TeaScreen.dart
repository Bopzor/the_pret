import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:the_pret_flutter/adaptive_font_size.dart';
import 'package:the_pret_flutter/app_localization.dart';
import 'package:the_pret_flutter/Timer.dart';

class TeaScreen extends StatelessWidget {
  TeaScreen({
    Key key,
    @required this.tea,
    @required this.archiveTea,
    @required this.removeTea,
    @required this.updateTea,
    @required this.notifications,
  }) : super(key: key);

  final dynamic tea;
  final Function archiveTea;
  final Function removeTea;
  final Function updateTea;
  final FlutterLocalNotificationsPlugin notifications;

  EdgeInsets setPadding(context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return EdgeInsets.all(0);
    }

    return EdgeInsets.only(bottom: 20, top: 20, right: 20, left: 20);
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
          label: AppLocalizations.of(context).translate('edit'),
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.amberAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.archive, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () {
            archiveTea(tea);
            Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) =>  false);
          },
          label: AppLocalizations.of(context).translate('archive'),
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.delete, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () {
            removeTea(tea);
            Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) =>  false);
          },
          label: AppLocalizations.of(context).translate('delete'),
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
                                style: TextStyle(fontSize: AdaptiveFontSize().getadaptiveTextSize(context, 60), fontWeight: FontWeight.bold),
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
                        cbAtEnd: () => updateTea({...tea, 'count': tea['count'] + 1}),
                        notifications: notifications,
                        minutes: tea['time']['minutes'],
                        seconds: tea['time']['seconds'],
                        // minutes: 0,
                        // seconds: 15,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: tea['temperature'],
                            style: TextStyle(fontSize: AdaptiveFontSize().getadaptiveTextSize(context, 60), color: Colors.black)
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
