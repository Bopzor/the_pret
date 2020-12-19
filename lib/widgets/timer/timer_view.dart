import 'package:flutter/material.dart';
import 'package:the_pret_flutter/abstract/widget_view.dart';
import 'package:the_pret_flutter/utils/adaptive_font_size.dart';
import 'package:the_pret_flutter/widgets/timer/timer.dart';

class TimerView extends WidgetView<TeaTimer, TimerController> {
  TimerView(TimerController state) : super(state);

    @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: MediaQuery.of(context).size.width * 0.7,
      constraints: BoxConstraints(
        minHeight: 100,
        minWidth: 100,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              constraints: BoxConstraints(
                minHeight: 100,
                minWidth: 100,
              ),
              child:
                CircularProgressIndicator(
                  value: state.percentage,
                  backgroundColor: Theme.of(context).backgroundColor,
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                  strokeWidth: 15,
                ),
              ),
          ) ,

          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [...state.displayTime(context)],
            ),
          ),

          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: IconButton(
                icon: state.displayIcon(),
                iconSize: AdaptiveFontSize().getadaptiveTextSize(context, 60.0),
                onPressed: state.toggleTimer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
