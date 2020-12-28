import 'package:flutter/material.dart';
import 'package:the_pret_flutter/utils/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({
    Key key,
    @required this.displayArchived,
    @required this.updateDisplayArchived,
    @required this.exportTeaList,
  });

  final bool displayArchived;
  final Function updateDisplayArchived;
  final Function exportTeaList;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Stack(
              children: [
                Image.asset('logo.png'),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    AppLocalizations.of(context).translate('title'),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          SwitchListTile(
            title: Text(
                AppLocalizations.of(context).translate('displayArchived')),
            value: displayArchived,
            onChanged: (bool value) {
              updateDisplayArchived(value);
            },
            activeColor: Theme.of(context).primaryColor,
            secondary: Icon(Icons.archive),
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context).translate('importFromFile')),
            leading: Icon(Icons.upload_file),
            onTap: () {
              Navigator.of(context).pushNamed('/import');
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).translate('exportList')),
            leading: Icon(Icons.save),
            onTap: () {
              exportTeaList();
            },
          ),
          Expanded(child: Container()),
          Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Made with ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    )),
                Icon(Icons.favorite, color: Colors.pink, size: 12),
                Text(' by ',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic)),
                GestureDetector(
                  child: Text('bopzor',
                      style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          color: Colors.blue)),
                  onTap: () => launch('https://github.com/bopzor'),
                ),
                Text(
                  " for M'man",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic),
                ),
                Text(
                  " 🐸",
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
