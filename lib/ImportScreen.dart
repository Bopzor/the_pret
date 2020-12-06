import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:the_pret_flutter/AppLocalizations.dart';

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
        setState(() {
          _teasList = teasList;
          _error = null;
        });
      } else {
        setState(() => _error = 'Invalid file');
      }
    } catch (e) {
      print(e.toString());
      setState(() => _error = 'Invalid file');

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () => _openFileExplorer(),
                      child: Text(AppLocalizations.of(context).translate('browseFile')),
                    ),
                    Builder(
                      builder: (BuildContext context) => _loadingPath
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: const CircularProgressIndicator(),
                          )
                          : _path != null
                            ? Container(
                                padding: const EdgeInsets.only(bottom: 30.0),
                                height: 50,
                                child: Scrollbar(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(_error == null ? Icons.check : Icons.close, color: _error == null ? Theme.of(context).accentColor : Colors.red),
                                      () {
                                        final String name = _fileName.split('/')[_fileName.split('/').length -1];

                                        return Text(name, style: TextStyle(fontSize: 20),);
                                      }(),
                                    ],
                                    )
                                ),
                              )
                            : const SizedBox(),
                    ),
                    ElevatedButton(
                      onPressed: _teasList == null ? null : () => widget.mergeTeas(_teasList),
                      child: Text(AppLocalizations.of(context).translate('import')),
                    ),
                    Text(
                      _error == null ? '' : AppLocalizations.of(context).translate('invalidFile'),
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ],
                ),
              ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
