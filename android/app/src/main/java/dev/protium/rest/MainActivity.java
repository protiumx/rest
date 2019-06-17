package dev.protium.rest;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.util.Log;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
  static final String TAG = "rest";
  static final String CHANNEL = "dev.protium.rest/service";

  AppService appService;
  boolean serviceConnected = false;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            (call, result) -> {
              if (!serviceConnected) {
                result.error(null, "Service not connected", null);
                return;
              }

              try {
                if (call.method.equals("start")) {
                  appService.startTimer(call.argument("duration"));
                  result.success(null);
                } else if (call.method.equals("stop")){
                  appService.stopTimer();
                  result.success(null);
                } else if (call.method.equals("getRemainingTime")) {
                  result.success(appService.getRemainingTime());
                }
              } catch (Exception e) {
                result.error(null, e.getMessage(), null);
              }
            });
  }

  @Override
  protected void onStart() {
    super.onStart();

    if (!serviceConnected) {
      Intent intent = new Intent(this, AppService.class);
      bindService(intent, connection, Context.BIND_AUTO_CREATE);
    } else {
      Log.i(TAG, "Service already connected");
    }
  }

  @Override
  protected void onStop() {
    super.onStop();
    unbindService(connection);
    serviceConnected = false;
  }

  private ServiceConnection connection = new ServiceConnection() {

    @Override
    public void onServiceConnected(ComponentName className,
                                   IBinder service) {
      AppService.AppServiceBinder binder = (AppService.AppServiceBinder)service;
      appService = binder.getService();
      serviceConnected = true;
      Log.i(TAG, "Service connected");
    }

    @Override
    public void onServiceDisconnected(ComponentName arg0) {
      serviceConnected = false;
      Log.i(TAG, "service disconnected");
    }
  };
}
