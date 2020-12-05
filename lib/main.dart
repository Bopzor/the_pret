import 'package:flutter/material.dart';
import 'package:the_pret_flutter/ImportScreen.dart';
import 'package:the_pret_flutter/UpsertScreen.dart';
import 'package:the_pret_flutter/TeaCard.dart';
import 'package:the_pret_flutter/data/LocalKeyValuePersistence.dart';
import 'package:the_pret_flutter/TeaScreen.dart';
import 'package:the_pret_flutter/UnknownScreen.dart';

void main() async {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final LocalKeyValuePersistence storage = LocalKeyValuePersistence();
  List<dynamic> teaList = [];
  String title = 'Thé Prêt ?';
  bool displayArchived = false;

  void initState() {
    super.initState();

    storage.getObject().then((response) {
      setState(() {
        teaList = response ?? [];
      });
    });

    storage.getString().then((value) {
      setState(() => displayArchived = value == 'true' ? true : false);
    });
  }

  void saveTea(Map<String, dynamic> tea) {
    setState(() {
      teaList.add(tea);
    });

    storage.saveObject(teaList);
  }

  void updateTea(Map<String, dynamic> tea) {
    int idx = teaList.indexWhere((element) => element['id'] == tea['id']);
    print(idx);
    setState(() {
      teaList.replaceRange(idx, idx + 1, [tea]);
    });

    storage.saveObject(teaList);
  }

  void archiveTea(Map<String, dynamic> tea) {
    int idx = teaList.indexWhere((element) => element['id'] == tea['id']);

    tea['archive'] = !tea['archive'];

    setState(() {
      teaList.replaceRange(idx, idx + 1, [tea]);
    });

    storage.saveObject(teaList);
  }

  void removeTea(Map<String, dynamic> tea) {
    int idx = teaList.indexWhere((element) => element['id'] == tea['id']);

    setState(() {
      teaList.replaceRange(idx, idx + 1, []);
    });

    storage.saveObject(teaList);
  }

  void updateDisplayArchived(bool value) {
    setState(() => displayArchived = value);

    storage.saveString(value.toString());
  }

  void mergeTeas(List<Map<String, dynamic>> teas) {
    setState(() {
      teaList.addAll(teas);
    });

    storage.saveObject(teaList);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        // Handle '/'
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) {
              return MyHomePage(
                title: this.title,
                saveTea: this.saveTea,
                teaList: this.teaList,
                displayArchived: this.displayArchived,
                updateDisplayArchived: this.updateDisplayArchived,
              );
            }
          );
        }

        if (settings.name == '/add') {
          return MaterialPageRoute(builder: (context) => UpsertScreen(title: title, saveTea: this.saveTea));
        }

        if (settings.name == '/import') {
          return MaterialPageRoute(builder: (context) => ImportScreen(title: title, mergeTeas: this.mergeTeas));
        }

        Uri uri = Uri.parse(settings.name);

        if (uri.pathSegments.length == 2) {
          String id = uri.pathSegments[1];
          int idx = teaList.indexWhere((t) => t['id'] == id);
          dynamic tea = teaList[idx];

          if (uri.pathSegments.first == 'tea') {
            return MaterialPageRoute(builder: (context) => TeaScreen(tea: tea, archiveTea: archiveTea, removeTea: removeTea));
          }

          if (uri.pathSegments.first == 'edit') {
            return MaterialPageRoute(builder: (context) => UpsertScreen(title: title, saveTea: this.updateTea, tea: tea));
          }

        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(
        title: title,
        saveTea: this.saveTea,
        teaList: this.teaList,
        displayArchived: this.displayArchived,
        updateDisplayArchived: this.updateDisplayArchived,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.saveTea, this.teaList, this.displayArchived, this.updateDisplayArchived}) : super(key: key);

  final String title;
  final Function saveTea;
  final List<dynamic> teaList;
  final bool displayArchived;
  final Function updateDisplayArchived;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showSearchbar = false;
  String query = '';
  TextEditingController search = TextEditingController();

   void dispose() {
    search.dispose();
    super.dispose();
  }

  bool isMatchingTea(tea) {
    String brandName = tea['name'] + ' ' + tea['brand'];

    if (showSearchbar == false || search.text == '') {
      if (tea['archive'] && widget.displayArchived == false) {
        return false;
      }

      return true;
    }

    if (brandName.toLowerCase().contains(search.text.trim().toLowerCase())) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!showSearchbar)
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  showSearchbar = true;
                });
              },
            ),
          if (showSearchbar)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Container(
                  width: 200,
                  child: TextFormField(
                    autofocus: true,
                    controller: search,
                    onChanged: (value) {
                      setState(() {
                        query = value;
                      });
                    },
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          search.clear();

                          setState(() {
                            query = '';
                            showSearchbar = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(widget.title, style: TextStyle(fontSize:  20, color: Colors.white)),
              decoration: BoxDecoration(color: Theme.of(context).accentColor),
            ),
            SwitchListTile(
              title: Text('Display archived teas in list'),
              value: widget.displayArchived,
              onChanged: (bool value) {
                widget.updateDisplayArchived(value);
              },
              secondary: Icon(Icons.archive),
            ),
            ListTile(
              title: Text('Import tea list from file'),
              onTap: () {
                Navigator.of(context).pushNamed('/import');
              },
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          children: [
                            ...widget.teaList.where((tea) => isMatchingTea(tea))
                              .map((tea) => TeaCard(tea: tea)).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        tooltip: 'Add tea',
        child: Icon(Icons.add),
      ),
    );
  }
}
