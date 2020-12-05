import 'package:flutter/material.dart';

class UnknownScreen extends StatelessWidget {
  UnknownScreen({Key key, this.tea}) : super(key: key);

  final tea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thé Prêt?')),
      body: Center(child: Text('404 page not found')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        tooltip: 'Go home',
        child: Icon(Icons.home),
      ),
    );
  }
}
