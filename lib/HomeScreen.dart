import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:the_pret_flutter/app_localization.dart';
import 'package:the_pret_flutter/TeaCard.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key key,
    @required this.saveTea,
    @required this.teasList,
    @required this.displayArchived,
    @required this.updateDisplayArchived
  }) : super(key: key);

  final Function saveTea;
  final List<dynamic> teasList;
  final bool displayArchived;
  final Function updateDisplayArchived;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSearchbar = false;
  String query = '';
  TextEditingController search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  bool isMatchingTea(Map<String, dynamic> tea) {
    String brandName = tea['name'] + ' ' + tea['brand'];

    if (showSearchbar == false || search.text == '') {
      if (!tea.containsKey('archived')) {
        return true;
      }

      if (tea['archived'] && widget.displayArchived == false) {
        return false;
      }

      return true;
    }

    if (brandName.toLowerCase().contains(search.text.trim().toLowerCase())) {
      return true;
    }

    return false;
  }

  List<dynamic> sortedList() {
    List<dynamic> list = widget.teasList;

    list.sort((a, b)  {
      int aCount = a['count'] is String ? int.parse(a['count']) : a['count'];
      int bCount = b['count'] is String ? int.parse(b['count']) : b['count'];

      return bCount.compareTo(aCount);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
        actions: [
          if (!showSearchbar)
            IconButton(
              icon: Icon(Icons.search),
              tooltip: AppLocalizations.of(context).translate('search'),
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
        child: Column(
          children: [
            DrawerHeader(
              child:
                Stack(
                  children: [
                    Image.asset('logo.png'),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        AppLocalizations.of(context).translate('title'),
                        style: TextStyle(fontSize:  20, color: Colors.white),
                      ),
                    ),
                  ],
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            SwitchListTile(
              title: Text(AppLocalizations.of(context).translate('displayArchived')),
              value: widget.displayArchived,
              onChanged: (bool value) {
                widget.updateDisplayArchived(value);
              },
              activeColor: Theme.of(context).primaryColor,
              secondary: Icon(Icons.archive),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).translate('importFromFile')),
              leading: Icon(Icons.upload_file),
              onTap: () {
                Navigator.of(context).pushNamed('/import');
              },
            ),
            Expanded(child: Container()),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Made with ', style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic,)),
                  Icon(Icons.favorite, color: Colors.pink, size: 12),
                  Text(' by ', style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                  GestureDetector(
                    child: Text('bopzor', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, decoration: TextDecoration.underline, color: Colors.blue)),
                    onTap: () => launch('https://github.com/bopzor'),
                  ),
                  Text(" for M'man", style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic),),
                  Text(" 🐸", style: TextStyle(fontSize: 10),),
                ],
              ),
            ),
          ],
        ),
      ),

      body:  LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
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
                            ...sortedList()
                              .where((tea) => isMatchingTea(tea)).toList()
                              .map((tea) => TeaCard(tea: tea)).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        tooltip: AppLocalizations.of(context).translate('addTea'),
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
