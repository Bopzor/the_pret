import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:the_pret_flutter/data/FileStorage.dart';
import 'package:the_pret_flutter/data/LocalKeyValuePersistence.dart';

import 'package:the_pret_flutter/localization/AppLanguage.dart';

import 'package:the_pret_flutter/app/app_view.dart';
import 'package:the_pret_flutter/screens/home/home.dart';
import 'package:the_pret_flutter/screens/import/import.dart';
import 'package:the_pret_flutter/screens/tea/tea.dart';
import 'package:the_pret_flutter/screens/unknown.dart';
import 'package:the_pret_flutter/UpsertScreen.dart';

class App extends StatefulWidget {
  final AppLanguage appLanguage;
  final NotificationAppLaunchDetails notificationAppLaunchDetails;

  App({this.appLanguage, this.notificationAppLaunchDetails});

  @override
  AppController createState() => AppController();
}

class AppController extends State<App> {
  final LocalKeyValuePersistence persistence = LocalKeyValuePersistence();
  final FileStorage storage = FileStorage();

  List<dynamic> teasList = [];
  bool displayArchived = false;
  FlutterLocalNotificationsPlugin notifications;

  void initState() {
    storage.readFile().then((response) {
      setState(() {
        teasList = response ?? [];
      });
    });

    persistence.getString().then((value) {
      setState(() => displayArchived = value == 'true' ? true : false);
    });

    AndroidInitializationSettings initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS = new IOSInitializationSettings();
    InitializationSettings initializationSettings = new InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    setState(() {
      notifications = flutterLocalNotificationsPlugin;
    });

    super.initState();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  void saveTea(Map<String, dynamic> tea) {
    setState(() {
      teasList.add(tea);
    });

    storage.writeFile(teasList);
  }

  void updateTea(Map<String, dynamic> tea) {
    int idx = teasList.indexWhere((element) => element['id'] == tea['id']);

    setState(() {
      teasList.replaceRange(idx, idx + 1, [tea]);
    });

    storage.writeFile(teasList);
  }

  void removeTea(Map<String, dynamic> tea) {
    int idx = teasList.indexWhere((element) => element['id'] == tea['id']);

    setState(() {
      teasList.replaceRange(idx, idx + 1, []);
    });

    storage.writeFile(teasList);
  }

  void archiveTea(Map<String, dynamic> tea) {
    int idx = teasList.indexWhere((element) => element['id'] == tea['id']);

    tea['archived'] = !tea['archived'];

    setState(() {
      teasList.replaceRange(idx, idx + 1, [tea]);
    });

    storage.writeFile(teasList);
  }

  void updateDisplayArchived(bool value) {
    setState(() => displayArchived = value);

    persistence.saveString(value.toString());
  }

  void mergeTeas(dynamic teas) {
    setState(() {
      teasList.addAll(teas);
    });

    storage.writeFile(teasList);
  }

  MaterialPageRoute getRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
            saveTea: saveTea,
            teasList: teasList,
            displayArchived: displayArchived,
            updateDisplayArchived: updateDisplayArchived,
          );
        }
      );
    }

    if (settings.name == '/add') {
      return MaterialPageRoute(builder: (context) => UpsertScreen(saveTea: saveTea));
    }

    if (settings.name == '/import') {
      return MaterialPageRoute(builder: (context) => ImportScreen(mergeTeas: mergeTeas));
    }

    Uri uri = Uri.parse(settings.name);

    if (uri.pathSegments.length == 2) {
      String id = uri.pathSegments[1];
      int idx = teasList.indexWhere((t) => t['id'] == id);
      dynamic tea = teasList[idx];

      if (uri.pathSegments.first == 'tea') {
        return MaterialPageRoute(builder: (context) {
          return TeaScreen(
            tea: tea,
            archiveTea: archiveTea,
            removeTea: removeTea,
            updateTea: updateTea,
            notifications: notifications,
          );
        });
      }

      if (uri.pathSegments.first == 'edit') {
        return MaterialPageRoute(builder: (context) => UpsertScreen(saveTea: updateTea, tea: tea));
      }
    }

    return MaterialPageRoute(builder: (context) => UnknownScreen());
  }

  @override
  Widget build(BuildContext context) => AppView(this);
}
