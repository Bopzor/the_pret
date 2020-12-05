import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tea-list.thepret.json');
  }

  Future<List<dynamic>> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return JsonDecoder().convert(contents);
    } catch (e) {
      // If encountering an error, return null
      return null;
    }
  }

  Future<File> writeFile(List<dynamic> teasList) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(JsonEncoder().convert(teasList));
  }
}
