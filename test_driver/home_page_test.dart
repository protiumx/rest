import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('scrolling performance test', ()
  {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('Start and stop timer', () async {
      // Give time to acept permission
      await Future<void>.delayed(Duration(seconds: 5));
      await driver.tap(find.text('start'));
      await driver.waitFor(find.text('stop'));
      await Future<void>.delayed(Duration(seconds: 5));
      await driver.tap(find.text('stop'));
      await driver.waitFor(find.text('start'));
    });
  });
}