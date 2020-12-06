import 'package:flutter/material.dart';
import 'package:the_pret_flutter/App.dart';
import 'package:the_pret_flutter/AppLanguage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  runApp(App(
    appLanguage: appLanguage,
  ));
}
