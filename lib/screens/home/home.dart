import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_pret_flutter/localization/app_localization.dart';
import 'package:the_pret_flutter/screens/home/home_view.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen(
    {Key key,
    @required this.saveTea,
    @required this.teasList,
    @required this.displayArchived,
    @required this.updateDisplayArchived})
    : super(key: key);

  final Function saveTea;
  final List<dynamic> teasList;
  final bool displayArchived;
  final Function updateDisplayArchived;

  @override
  HomeScreenController createState() => HomeScreenController();
}

class HomeScreenController extends State<HomeScreen> {
  bool showSearchbar = false;
  String query = '';
  TextEditingController search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  void displaySearch() {
    setState(() {
      showSearchbar = true;
    });
  }

  void onSearch(String value) {
    setState(() {
      query = value;
    });
  }

  void onCancelSearch() {
    search.clear();

    setState(() {
      query = '';
      showSearchbar = false;
    });
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

    list.sort((a, b) {
      int aCount = a['count'] is String ? int.parse(a['count']) : a['count'];
      int bCount = b['count'] is String ? int.parse(b['count']) : b['count'];

      return bCount.compareTo(aCount);
    });

    return list;
  }

  Future<void> exportTeaList() async {
    final storageDirectory = await getExternalStorageDirectory();
    final storageDirectoryPath = storageDirectory.path;

    final file = File('$storageDirectoryPath/the-pret-list${DateTime.now().millisecondsSinceEpoch}.json');

    file
      .writeAsString(JsonEncoder().convert(widget.teasList))
      .then((File _file) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar(context));
        Navigator.pop(context);
    });
  }

  SnackBar snackBar(context) {
    return SnackBar(content: Text(AppLocalizations.of(context).translate('saved'),), backgroundColor: Colors.teal,);
  }

  @override
  Widget build(BuildContext context) => HomeScreenView(this);
}
