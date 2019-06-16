package dev.protium.rest;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;
import android.widget.Toast;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.content.Intent.FLAG_ACTIVITY_NEW_TASK;

public class MainActivity extends FlutterActivity {
  static final String TAG = "rest";


  AppService appService;
  boolean serviceBounded = false;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }

  @Override
  protected void onStart() {
    super.onStart();

    if (!serviceBounded) {
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
    serviceBounded = false;
  }

  private ServiceConnection connection = new ServiceConnection() {

    @Override
    public void onServiceConnected(ComponentName className,
                                   IBinder service) {
      AppService.AppServiceBinder binder = (AppService.AppServiceBinder)service;
      appService = binder.getService();
      serviceBounded = true;
      Log.i(TAG, "Service connected");
    }

    @Override
    public void onServiceDisconnected(ComponentName arg0) {
      serviceBounded = false;
      Log.i(TAG, "service disconnected");
    }
  };
}
