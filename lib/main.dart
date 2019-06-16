import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';

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
  final int _defaultDuration = 20 * 60; // 20 minutes
  final int _minDuration = 5 * 60; // adds or substracts 5 minutes
  final int _maxDuration = 60 * 60; // one hour

  // State
  int _currentSeconds;
  Timer _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _currentSeconds = _defaultDuration;
  }

  String formatTime(int total) {
    int minutes = (total / 60).floor();
    int seconds = total - minutes * 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    // Avoid errors with test runner
    _timer?.cancel();
    super.dispose();
  }

  void changeTimerDuration(bool substract) {
    int newDuration = substract
        ? _currentSeconds - _minDuration
        : _currentSeconds + _minDuration;

    if (newDuration < _minDuration || newDuration > _maxDuration) {
      if (Vibration.hasVibrator() != null) {
        Vibration.vibrate(duration: 200);
      }
      return;
    }
    setState(() {
      _currentSeconds = newDuration;
    });
  }

  void updateTimer() {
    if (_currentSeconds == 1) {
      _timer.cancel();
      _currentSeconds = _defaultDuration;
      _started = false;
    } else {
      _currentSeconds--;
    }
  }

  void toggleTimer() {
    setState(() {
      const oneSecond = const Duration(seconds: 1);
      if (!_started) {
        _timer = new Timer.periodic(
            oneSecond, (Timer timer) => setState(updateTimer));

        _currentSeconds--;
        _started = true;
      } else {
        _timer.cancel();
        _started = false;
        _currentSeconds = _defaultDuration;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Visibility(
                  visible: !_started,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: FloatingActionButton(
                      backgroundColor: Colors.grey,
                      onPressed:
                          _started ? null : () => changeTimerDuration(true),
                      tooltip: 'substract 5 min',
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      )),
                ),
                Text(
                  _currentSeconds < 0 ? '' : formatTime(_currentSeconds),
                  style: TextStyle(fontSize: 80),
                ),
                Visibility(
                  visible: !_started,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: FloatingActionButton(
                      backgroundColor: Colors.grey,
                      onPressed:
                          _started ? null : () => changeTimerDuration(false),
                      tooltip: 'add 5 min',
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
            RaisedButton(
              onPressed: toggleTimer,
              child: Text(_started ? 'stop' : 'start',
                  style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
