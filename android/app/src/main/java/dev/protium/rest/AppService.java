package dev.protium.rest;

import android.app.Service;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Binder;
import android.os.IBinder;
import android.os.SystemClock;
import android.util.Log;
import android.view.KeyEvent;

import java.util.Timer;
import java.util.TimerTask;

public class AppService extends Service {
    private final IBinder binder = new AppServiceBinder();
    private final String TAG = "rest/service";
    Timer _timer;
    int _currentSeconds = 0;

    @Override
    public void onCreate() {
        super.onCreate();        
        _timer = new Timer();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        _timer.cancel();
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return binder;
    }

    public class AppServiceBinder extends Binder {
        AppService getService() {
            return  AppService.this;
        }
    }

    public void startTimer(int duration) {
        _currentSeconds = duration - 1;

        _timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                if (_currentSeconds == 1) {
                    _timer.cancel();
                    Log.i(TAG, "Timer stopped");
                    _currentSeconds = 0;
                    try {
                        AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);
                        if (am.isMusicActive()) {
                            long eventtime = SystemClock.uptimeMillis();
                            KeyEvent downEvent = new KeyEvent(eventtime, eventtime, KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PAUSE, 0);
                            am.dispatchMediaKeyEvent(downEvent);
                            KeyEvent upEvent = new KeyEvent(eventtime, eventtime, KeyEvent.ACTION_UP, KeyEvent.KEYCODE_MEDIA_PAUSE, 0);
                            am.dispatchMediaKeyEvent(upEvent);
                        }
                        Log.i(TAG, "Music paused");
                    } catch (Exception e) {
                        Log.e(TAG, "Can't pause music. " + e.getMessage());
                    }
                }
                else {
                    _currentSeconds--;
                }
            }
        }, 0, 1000);

        Log.i(TAG, "Timer started");
    }

    public void stopTimer() {
        _timer.cancel();
        Log.i(TAG, "Timer stopped");
    }

    public int getRemainingTime() {
        return _currentSeconds;
    }
}
