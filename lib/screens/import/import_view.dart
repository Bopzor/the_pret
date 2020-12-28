import 'package:flutter/material.dart';

import 'package:the_pret_flutter/abstract/widget_view.dart';
import 'package:the_pret_flutter/utils/localization/app_localization.dart';
import 'package:the_pret_flutter/screens/import/import.dart';

class ImportScreenView extends WidgetView<ImportScreen, ImportScreenController> {
  ImportScreenView(ImportScreenController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
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
                      onPressed: state.openFileExplorer,
                      child: Text(AppLocalizations.of(context).translate('browseFile')),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                      ),
                    ),
                    Builder(
                      builder: (BuildContext context) => state.loadingPath
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: const CircularProgressIndicator(),
                          )
                          : state.path != null
                            ? Container(
                                padding: const EdgeInsets.only(bottom: 30.0),
                                height: 50,
                                child: Scrollbar(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(state.error == null ? Icons.check : Icons.close, color: state.error == null ? Theme.of(context).primaryColor : Colors.red),
                                      () {
                                        final String name = state.fileName.split('/')[state.fileName.split('/').length -1];

                                        return Text(name, style: TextStyle(fontSize: 20),);
                                      }(),
                                    ],
                                    )
                                ),
                              )
                            : const SizedBox(),
                    ),
                    ElevatedButton(
                      onPressed: state.teasList == null ? null : () {
                        widget.mergeTeas(state.teasList);
                        Navigator.of(context).pushNamed('/');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).primaryColor,
                        onPrimary: Colors.white,
                      ),
                      child: Text(AppLocalizations.of(context).translate('import')),
                    ),
                    Text(
                      state.error == null ? '' : AppLocalizations.of(context).translate('invalidFile'),
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
