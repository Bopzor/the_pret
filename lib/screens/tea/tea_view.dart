import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:the_pret_flutter/utils/adaptive_font_size.dart';
import 'package:the_pret_flutter/localization/app_localization.dart';
import 'package:the_pret_flutter/abstract/widget_view.dart';

import 'package:the_pret_flutter/screens/tea/tea.dart';
import 'package:the_pret_flutter/widgets/timer/timer.dart';

class TeaScreenView extends WidgetView<TeaScreen, TeaScreenController> {
  TeaScreenView(TeaScreenController state) : super(state);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tea['name'])),
      body: Center(
        child: Padding(
          padding: state.setPadding(context),
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
                                widget.tea['name'],
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
                                  widget.tea['brand'],
                                  style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic, color: Colors.grey)
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      TeaTimer(
                        cbAtEnd: state.incrementCount,
                        notifications: widget.notifications,
                        minutes: state.tea['time']['minutes'],
                        seconds: state.tea['time']['seconds'],
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: widget.tea['temperature'],
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
      floatingActionButton: TeadSpeedDial(tea: state.tea, archiveTea: widget.archiveTea, removeTea: widget.removeTea,),
    );
  }
}

class TeadSpeedDial extends StatelessWidget {
  TeadSpeedDial({
    Key key,
    @required this.tea,
    @required this.archiveTea,
    @required this.removeTea,
  }) : super(key: key);

  final tea;
  final Function archiveTea;
  final Function removeTea;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      backgroundColor: Theme.of(context).primaryColor,
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
          label: AppLocalizations.of(context).translate(tea['archived'] ? 'unarchive' : 'archive'),
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
}
