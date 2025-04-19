import 'package:flutter/material.dart';

import 'package:appbt/view/listview.dart'; // Assuming your NoteItem widget is here


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notes App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: NoteView(), // Pass the note object here
    );
  }

// Sample Note object to pass to the NoteItem1 widget


}
