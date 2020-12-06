import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_pret_flutter/AppLanguage.dart';
import 'package:the_pret_flutter/HomeScreen.dart';
import 'package:the_pret_flutter/ImportScreen.dart';
import 'package:the_pret_flutter/TeaScreen.dart';
import 'package:the_pret_flutter/UnknownScreen.dart';
import 'package:the_pret_flutter/UpsertScreen.dart';
import 'package:the_pret_flutter/app_localization.dart';
import 'package:the_pret_flutter/data/FileStorage.dart';
import 'package:the_pret_flutter/data/LocalKeyValuePersistence.dart';

class App extends StatefulWidget {
  final AppLanguage appLanguage;

  App({this.appLanguage});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final LocalKeyValuePersistence persistence = LocalKeyValuePersistence();
  final FileStorage storage = FileStorage();
  List<dynamic> teasList = [];
  bool displayArchived = false;

  void initState() {
    super.initState();

    storage.readFile().then((response) {
      setState(() {
        teasList = response ?? [];
      });
    });

    persistence.getString().then((value) {
      setState(() => displayArchived = value == 'true' ? true : false);
    });

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

  void archiveTea(Map<String, dynamic> tea) {
    int idx = teasList.indexWhere((element) => element['id'] == tea['id']);

    tea['archived'] = !tea['archived'];

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
        Locale('fr'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateRoute: (settings) {
        // Handle '/'
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) {
              return HomeScreen(
                saveTea: this.saveTea,
                teasList: this.teasList,
                displayArchived: this.displayArchived,
                updateDisplayArchived: this.updateDisplayArchived,
              );
            }
          );
        }

        if (settings.name == '/add') {
          return MaterialPageRoute(builder: (context) => UpsertScreen(saveTea: this.saveTea));
        }

        if (settings.name == '/import') {
          return MaterialPageRoute(builder: (context) => ImportScreen(mergeTeas: this.mergeTeas));
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
              );
            });
          }

          if (uri.pathSegments.first == 'edit') {
            return MaterialPageRoute(builder: (context) => UpsertScreen(saveTea: this.updateTea, tea: tea));
          }
        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Lato'
      ),
      home: HomeScreen(
        saveTea: this.saveTea,
        teasList: this.teasList,
        displayArchived: this.displayArchived,
        updateDisplayArchived: this.updateDisplayArchived,
      ),
    );
  }
}
