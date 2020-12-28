import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:the_pret_flutter/abstract/widget_view.dart';
import 'package:the_pret_flutter/utils/localization/app_localization.dart';

import 'package:the_pret_flutter/screens/upsert/upsert.dart';

class UpsertView extends WidgetView<UpsertScreen, UpsertController> {
  UpsertView(UpsertController state) : super(state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context).translate('title'))),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(fontSize: 30),
                      textCapitalization: TextCapitalization.sentences,
                      controller: state.nameController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('name'),
                      ),
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 30),
                      textCapitalization: TextCapitalization.sentences,
                      controller: state.brandController,
                      decoration: InputDecoration(
                        labelText:
                            AppLocalizations.of(context).translate('brand'),
                      ),
                    ),
                    Container(
                      width: 80,
                      child: TextFormField(
                        style: TextStyle(fontSize: 30),
                        textCapitalization: TextCapitalization.sentences,
                        controller: state.tempController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3)
                        ],
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context).translate('temp'),
                          suffixText: '°C',
                          isDense: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).translate('time'),
                              style: TextStyle(
                                  fontSize: 30, color: Colors.grey[700])),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: state.getInitialMinutes()),
                                  itemExtent: 50, //height of each item
                                  looping: true,
                                  onSelectedItemChanged: state.onMinutesChange,
                                  children: <Widget>[
                                    ...state.minutesOptions.map((options) {
                                      return (Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(options.toString(),
                                              style: TextStyle(fontSize: 30))
                                        ],
                                      ));
                                    })
                                  ],
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                      initialItem: state.getInitialSeconds()),
                                  itemExtent: 50, //height of each item
                                  looping: true,
                                  onSelectedItemChanged: state.onSecondsChange,
                                  children: <Widget>[
                                    ...state.secondsOptions.map((options) {
                                      return (Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            options
                                                .toString()
                                                .padLeft(2, '0'),
                                            style: TextStyle(fontSize: 30))
                                        ],
                                      ));
                                    })
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 50,
                            child:ElevatedButton(
                              onPressed: state.isButtonDisabled ? null : () {
                                state.onSaveTea();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                onPrimary: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context).translate('save'), style: TextStyle(fontSize: 30)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
