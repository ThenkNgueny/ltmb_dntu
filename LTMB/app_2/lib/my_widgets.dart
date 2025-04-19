import 'package:flutter/material.dart';

class MyStatelessWidget extends StatelessWidget {
  final String title;

  MyStatelessWidget({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  _MyStatefulWidget createState() => _MyStatefulWidget();
}

class _MyStatefulWidget extends State<MyStatefulWidget> {
  String title = 'Hello, Flutter!';

  void _updateTile() {
    setState(() {
      title = 'Title Updated';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(title),
        ElevatedButton(
          onPressed: _updateTile,
          child: Text('Update Title'),
        ),
      ],
    );
  }
}