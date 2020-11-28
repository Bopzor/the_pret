import 'package:flutter/material.dart';

class TeaCard extends StatelessWidget {
  TeaCard({Key key, this.tea}) : super(key: key);

  final tea;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.green.withAlpha(30),
        onTap: () {
          Navigator.pushNamed(context, '/tea' + '/' + tea['id']);
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: 150,
          ),
          width: MediaQuery.of(context).size.width * 0.45,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 60,
                      ),
                      child: Center(
                        child: Text(
                          tea['name'],
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            tea['brand'],
                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(tea['time']['minutes'] + ':', style: TextStyle(fontSize: 35)),
                        Text(tea['time']['seconds'], style: TextStyle(fontSize: 35)),
                      ],
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: tea['temperature'],
                          style: TextStyle(fontSize: 30, color: Colors.black)
                        ),
                        WidgetSpan(
                          child: Transform.translate(
                            offset: const Offset(2, -12),
                            child: Text(
                              '°C',
                              textScaleFactor: 1,
                            ),
                          ),
                        )
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}