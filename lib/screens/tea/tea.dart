import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:the_pret_flutter/utils/localization/app_localization.dart';
import 'package:the_pret_flutter/screens/tea/tea_view.dart';

class TeaScreen extends StatefulWidget {
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

  @override
  TeaScreenController createState() => TeaScreenController();
}

class TeaScreenController extends State<TeaScreen> {
  Map<String, dynamic> tea;

  @override
  void initState() {
    tea = widget.tea;

    super.initState();
  }

  EdgeInsets setPadding(context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return EdgeInsets.all(0);
    }

    return EdgeInsets.only(bottom: 20, top: 20, right: 20, left: 20);
  }

  void incrementCount() {
    int count = tea['count'] is String ? int.parse(tea['count']) : tea['count'];
    Map<String, dynamic> updatedTea = {...widget.tea, 'count': count + 1};

    setState(() {
      tea = updatedTea;
    });

    widget.updateTea(updatedTea);
  }

  showDeleteConfirmation(tea) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text(
          '${AppLocalizations.of(context).translate('delete')} ${tea['name']}${AppLocalizations.of(context).translate('?')}',
        ),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.grey,
            child: Text(AppLocalizations.of(context).translate('cancel')),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context).translate('delete')),
            style: ElevatedButton.styleFrom(
              primary: Colors.redAccent,
              onPrimary: Colors.white,
            ),
            onPressed: () {
              widget.removeTea(tea);
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) =>  false);
            },
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) => TeaScreenView(this);
}
