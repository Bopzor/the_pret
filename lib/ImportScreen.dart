import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

class ImportScreen extends StatefulWidget {
  ImportScreen({Key key, this.title, this.mergeTeas});

  final String title;
  final Function mergeTeas;

  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  PlatformFile _path;
  String _directoryPath;
  bool _loadingPath = false;
  dynamic _teasList;
  String _error;

  @override
  void initState() {
    super.initState();
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _path = (await FilePicker.platform.pickFiles(
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
      _loadingPath = false;
      _fileName = _path != null ? _path.path : '...';
    });

    if (_fileName != null) {
      readFile();
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles();
  }

  Future<void> readFile() async {
    try {
      final file = File(_fileName);
      String content = await file.readAsString();
      List<dynamic> teas = JsonDecoder().convert(content);
      List<String> missing = [];

      Iterable<Map<String, dynamic>> teasList = teas.map((element) {
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
        setState(() => _teasList = teasList);
      } else {
        setState(() => _error = 'Invalid file');
      }
    } catch (e) {
      print(e.toString());

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () => _openFileExplorer(),
                      child: Text("Open file picker"),
                    ),
                    RaisedButton(
                      onPressed: _teasList == null ? null : () => widget.mergeTeas(_teasList),
                      child: Text("Import"),
                    ),
                    RaisedButton(
                      onPressed: () => _clearCachedFiles(),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ),
              Builder(
                builder: (BuildContext context) => _loadingPath
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: const CircularProgressIndicator(),
                    )
                  : _directoryPath != null
                    ? ListTile(
                      title: Text('Directory path'),
                      subtitle: Text(_directoryPath),
                    )
                    : _path != null
                        ? Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height:
                                MediaQuery.of(context).size.height * 0.50,
                            child: Scrollbar(
                                child: ListView.separated(
                              itemCount: 1,
                              itemBuilder:
                                (BuildContext context, int index) {
                                  final String name = 'File ' + _fileName ?? '...';

                                  return ListTile(title: Text(name));
                                },
                                separatorBuilder:
                                  (BuildContext context, int index) =>
                                    const Divider(),
                              )
                            ),
                          )
                        : const SizedBox(),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
