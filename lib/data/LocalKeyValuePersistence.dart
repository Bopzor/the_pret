import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_pret_flutter/data/Repository.dart';

String key = 'tea-list';

class LocalKeyValuePersistence implements Repository {
  @override
  void saveObject(List<dynamic> object) async {
    final prefs = await SharedPreferences.getInstance();
    final string = JsonEncoder().convert(object);
    await prefs.setString(key, string);
  }

  @override
  Future<List<dynamic>> getObject() async {
    final prefs = await SharedPreferences.getInstance();
    final objectString = prefs.getString(key);
    if (objectString != null)
      return JsonDecoder().convert(objectString) as List<dynamic>;
    return null;
  }

  @override
  Future<void> removeObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

}
