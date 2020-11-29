import 'package:flutter/material.dart';
import 'package:the_pret_flutter/AddScreen.dart';
import 'package:the_pret_flutter/TeaCard.dart';
import 'package:the_pret_flutter/data/LocalKeyValuePersistence.dart';
import 'package:the_pret_flutter/data/TeaScreen.dart';
import 'package:the_pret_flutter/data/UnknownScreen.dart';

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

  void initState() {
    super.initState();

    storage.getObject().then((response) {
      setState(() {
        teaList = response ?? [];
      });

      print(teaList);
    });
  }

  void saveTea(Map<String, dynamic> tea) {
    setState(() {
      teaList.add(tea);
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
            builder: (context) => MyHomePage(title: 'Thé Prêt', saveTea: this.saveTea, teaList: this.teaList),
          );
        }

        // Handle '/add'
        if (settings.name == '/add') {
          return MaterialPageRoute(builder: (context) => AddScreen(title: 'Thé Prêt', saveTea: this.saveTea));
        }

        // Handle '/details/:id'
        Uri uri = Uri.parse(settings.name);

        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'tea') {
          String id = uri.pathSegments[1];
          int idx = teaList.indexWhere((t) => t['id'] == id);
          dynamic tea = teaList[idx];

          return MaterialPageRoute(builder: (context) => TeaScreen(tea: tea));
        }

        return MaterialPageRoute(builder: (context) => UnknownScreen());
      },
      title: 'Thé Prêt',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Thé Prêt', saveTea: this.saveTea, teaList: this.teaList),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.saveTea, this.teaList}) : super(key: key);

  final String title;
  final Function saveTea;
  final List<dynamic> teaList;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showSearchbar = false;
  String query = '';
  TextEditingController search = TextEditingController();

  bool isMatchingTea(tea) {
    String brandName = tea['name'] + ' ' + tea['brand'];

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
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                showSearchbar = !showSearchbar;
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
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(10),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          search.clear();

                          setState(() {
                            query = '';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...widget.teaList.where((tea) {
                  if (isMatchingTea(tea)) {
                    return true;
                  }

                  return false;
                })
                .map((tea) => TeaCard(tea: tea)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
        tooltip: 'Add tea',
        child: Icon(Icons.add),
      ),
    );
  }
}
