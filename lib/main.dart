import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rest',
      theme: ThemeData(primarySwatch: Colors.grey, brightness: Brightness.dark),
      home: MyHomePage(title: 'Rest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final int _defaultTimer = 1 * 60; // 20 minutes
  final int _minChange = 5 * 60; // adds or substracts 5 minutes
  final int _maxTimer = 60 * 60; // one hour

  // State
  int _currentSeconds;
  Timer _timer;
  bool _started = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
