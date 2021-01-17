import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:the_pret_flutter/utils/localization/app_localization.dart';

import 'package:the_pret_flutter/app/app.dart';
import 'package:the_pret_flutter/abstract/widget_view.dart';
import 'package:the_pret_flutter/screens/home/home.dart';

class AppView extends WidgetView<App, AppController> {
  AppView(AppController state) : super(state);

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
      onGenerateRoute: state.getRoute,
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.teal,
        backgroundColor: Colors.green,
        fontFamily: 'Lato',
      ),
      home: (state.teasList == null || state.shortcuts == null) ? Container() :
      HomeScreen(
        saveTea: state.saveTea,
        teasList: state.teasList,
        displayArchived: state.displayArchived,
        updateDisplayArchived: state.updateDisplayArchived,
        shortcut: state.shortcut,
      ),
    );
  }
}
