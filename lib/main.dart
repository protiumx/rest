import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rest',
      theme: ThemeData(primarySwatch: Colors.grey, brightness: Brightness.dark),
      home: Scaffold(
        body: MyHomePage(title: 'Rest'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static const int _defaultDuration = 20 * 60; // 20 minutes
  static const int _minDuration = 5 * 60; // adds or substracts 5 minutes
  static const int _maxDuration = 60 * 60; // one hour

  static const platform = const MethodChannel('dev.protium.rest/service');

  // State
  int _currentSeconds;
  Timer _timer;
  bool _started = false;
  bool _connectedToService = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentSeconds = _defaultDuration;
    connectToService();
  }

  Future connectToService() async {
    try {
      await platform.invokeMethod('connect');
      print('Connected to service');
      Scaffold.of(context).showSnackBar(
          SnackBar(content: const Text('Connected to app service'), duration: const Duration(seconds: 2))
      );
    } on Exception catch(e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
          SnackBar(content: const Text('Could not connect to app service.'))
      );
      return;
    }

    try {
      int serviceCurrentSeconds = await getServiceCurrentSeconds();
      setState(() {
        _connectedToService = true;
        if (serviceCurrentSeconds <= 0) {
          _currentSeconds = _defaultDuration;
          _started = false;
          _timer?.cancel();
        } else {
          _currentSeconds = serviceCurrentSeconds;
          _started = true;
          const oneSecond = const Duration(seconds: 1);
          _timer = new Timer.periodic(
              oneSecond, (Timer timer) => setState(updateTimer));
        }
      });
    } on PlatformException catch(e) {
      print(e.toString());
    } on Exception catch(e) {
      print(e.toString());
    }
  }

  Future startService(int duration) async {
    try {
      await platform.invokeMethod('start', { 'duration': duration});
    }  on PlatformException catch(e) {
      debugPrint(e.toString());
      throw e;
    }
  }

  Future stopService() async {
    try {
      await platform.invokeMethod('stop');
    }  on PlatformException catch(e) {
      debugPrint(e.toString());
      throw e;
    }
  }

  Future getServiceCurrentSeconds() async {
    try {
      int result = await platform.invokeMethod('getCurrentSeconds');
      return result;
    } on PlatformException catch(e) {
      print(e.toString());
    }

    return 0;
  }

  String formatTime(int total) {
    int minutes = (total / 60).floor();
    int seconds = total - minutes * 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.suspending) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      connectToService();
    }
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
    if (!_started) {
      startService(_currentSeconds).then((_) => setState(() {
        const oneSecond = const Duration(seconds: 1);
        _timer = new Timer.periodic(
        oneSecond, (Timer timer) => setState(updateTimer));

        _currentSeconds--;
        _started = true;
      }));
    } else {
     stopService().then((_) => setState(() {
       _timer.cancel();
       _started = false;
       _currentSeconds = _defaultDuration;
     }));
    }
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
              onPressed: _connectedToService ? toggleTimer : null,
              child: Text(_started ? 'stop' : 'start',
                  style: TextStyle(fontSize: 30)),
            ),
          ],
        ),
      ),
    );
  }
}
