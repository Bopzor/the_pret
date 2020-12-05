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
  List<PlatformFile> _paths;
  String _directoryPath;
  bool _loadingPath = false;
  FileType _pickingType = FileType.custom;

  @override
  void initState() {
    super.initState();
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    try {
      _directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: false,
        allowedExtensions: ['.thepret'],
      ))
        ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _paths != null ? _paths.map((e) => e.name).toString() : '...';
    });

    if (_paths != null) {
      readFile();
    }
  }

  void _clearCachedFiles() {
    FilePicker.platform.clearTemporaryFiles();
  }

  Future<void> readFile() async {
    try {
      final file = File(_paths[0].path);
      String content = await file.readAsString();

      print(content);
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
                      onPressed: () => _clearCachedFiles(),
                      child: Text("Clear temporary files"),
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
                    : _paths != null
                        ? Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height:
                                MediaQuery.of(context).size.height * 0.50,
                            child: Scrollbar(
                                child: ListView.separated(
                              itemCount:
                                _paths != null && _paths.isNotEmpty
                                  ? _paths.length
                                  : 1,
                              itemBuilder:
                                (BuildContext context, int index) {
                                  final String name = 'File $index: ' + _fileName ?? '...';
                                  final path = _paths
                                    .map((e) => e.path)
                                    .toList()[index]
                                    .toString();

                                  return ListTile(
                                    title: Text(
                                      name,
                                    ),
                                    subtitle: Text(path),
                                  );
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
