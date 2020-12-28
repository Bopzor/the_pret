import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_pret_flutter/screens/import/import_view.dart';

class ImportScreen extends StatefulWidget {
  ImportScreen({Key key, @required this.mergeTeas});

  final Function mergeTeas;

  @override
  ImportScreenController createState() => ImportScreenController();
}

class ImportScreenController extends State<ImportScreen> {
  String fileName;
  PlatformFile path;
  bool loadingPath = false;
  dynamic teasList;
  String error;

  void openFileExplorer() async {
    setState(() => loadingPath = true);
    try {
      path = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['.json'],
      ))
        ?.files?.single;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      loadingPath = false;
      fileName = path != null ? path.path : '...';
    });

    if (fileName != null) {
      readFile();
    }
  }

  Future<void> readFile() async {
    try {
      final file = File(fileName);
      String content = await file.readAsString();
      List<dynamic> teas = JsonDecoder().convert(content);
      List<String> missing = [];

      print('readFile');

      Iterable<Map<String, dynamic>> list = teas.map((element) {
        for (String key in ['id', 'name', 'brand', 'temperature', 'time']) {
          if (!element.keys.contains(key)) {
            missing.add(key);
          }
        }

        Map<String, dynamic> tea = {
          'id': element['id'],
          'name': element['name'],
          'brand': element['brand'],
          'archived': element['archived'],
          'count': element['count'],
          'time': element['time'],
        };

        if (!element.containsKey('count')) {
          tea['count'] = 0;
        }

        if (!element.containsKey('archived')) {
          tea['archived'] = false;
        }

        if (element['time']['minutes'] is String) {
          tea['time']['minutes'] = int.parse(element['time']['minutes']);
        }

        if (element['time']['seconds'] is String) {
          tea['time']['seconds'] = int.parse(element['time']['seconds']);
        }

        if (element['temperature'] is int) {
          tea['temperature'] = element['temperature'].toString();
        }

        return tea;
      });

      if (missing.length <= 0) {
        setState(() {
          teasList = list;
          error = null;
        });
      } else {
        setState(() => error = 'Invalid file');
      }
    } catch (e) {
      print(e.toString());
      setState(() => error = 'Invalid file');

      return;
    }
  }

  @override
  Widget build(BuildContext context) => ImportScreenView(this);
}
