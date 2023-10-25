import 'package:flutter/material.dart';
import 'package:rough/Homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserSelectionScreen(), // Use the UserSelectionScreen widget
    );
  }
}
