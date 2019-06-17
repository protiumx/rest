import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('scrolling performance test', ()
  {
    FlutterDriver driver;

    setUpAll(() async {
      // commands are note working properly
      final Map<String, String> envVars = Platform.environment;
      final String adbPath = envVars['ANDROID_HOME'] + '/platform-tools/adb';
      await Process.run(adbPath , <String>['shell' ,'pm', 'grant', 'dev.protium.rest', 'android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS']);
      await Process.run(adbPath , <String>['shell' ,'pm', 'grant', 'dev.protium.rest', 'android.permission.VIBRATE']);
      await Process.run(adbPath , <String>['shell dumpsys deviceidle whitelist +dev.protium.rest']);
      driver = await FlutterDriver.connect();
    });

    

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Start and stop timer', () async {
      await driver.tap(find.text('start'));
      await driver.waitFor(find.text('stop'));
      await Future<void>.delayed(Duration(seconds: 5));
      await driver.tap(find.text('stop'));
      await driver.waitFor(find.text('start'));
    });
  });
}