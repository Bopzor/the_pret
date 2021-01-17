import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<List<dynamic>> readFile(String fileName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$fileName');

      // Read the file
      String contents = await file.readAsString();

      return JsonDecoder().convert(contents);
    } catch (e) {
      // If encountering an error, return null
      return null;
    }
  }

  Future<File> writeTeasListAsFile(List<dynamic> teasList) async {
    final path = await _localPath;
    final file = File('$path/tea-list.thepret.json');

    // Write the file
    return file.writeAsString(JsonEncoder().convert(teasList));
  }

  Future<File> writeShortcutAsFile(List<dynamic> shortcuts) async {
    final path = await _localPath;
    final file = File('$path/shortcuts.thepret.json');

    // Write the file
    return file.writeAsString(JsonEncoder().convert(shortcuts));
  }
}
