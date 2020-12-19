import 'package:flutter/material.dart';
import 'package:the_pret_flutter/screens/home/home.dart';
import 'package:the_pret_flutter/widgets/tea_card.dart';
import 'package:the_pret_flutter/abstract/widget_view.dart';
import 'package:the_pret_flutter/localization/app_localization.dart';
import 'package:the_pret_flutter/widgets/drawer.dart';

class HomeScreenView extends WidgetView<HomeScreen, HomeScreenController> {
  HomeScreenView(HomeScreenController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
        actions: [
          if (!state.showSearchbar)
            IconButton(
              icon: Icon(Icons.search),
              tooltip: AppLocalizations.of(context).translate('search'),
              onPressed: state.displaySearch,
            ),
          if (state.showSearchbar)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Container(
                  width: 200,
                  child: TextFormField(
                    autofocus: true,
                    controller: state.search,
                    onChanged: state.onSearch,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: state.onCancelSearch,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: AppDrawer(
        displayArchived: widget.displayArchived,
        updateDisplayArchived: widget.updateDisplayArchived,
        exportTeaList: state.exportTeaList,
      ),
      body: LayoutBuilder(
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
                            ...state.sortedList()
                                .where((tea) => state.isMatchingTea(tea))
                                .toList()
                                .map((tea) => TeaCard(tea: tea))
                                .toList(),
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
