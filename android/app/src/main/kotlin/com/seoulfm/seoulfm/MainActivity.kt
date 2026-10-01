package com.seoulfm.seoulfm

import android.app.Activity
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceActivity shares one Flutter engine between the screen and the playback
// service, so Android Auto and the notification drive the same player as the app.
class MainActivity : AudioServiceActivity() {
    private var screenshots: MethodChannel? = null

    // Android 14+ tells a visible activity when the screen is captured; the player offers to
    // share the song. Earlier versions have no such callback.
    private val onCapture: Any? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            Activity.ScreenCaptureCallback { screenshots?.invokeMethod("taken", null) }
        } else {
            null
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        screenshots = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fm.seoul/screenshots")
    }

    override fun onStart() {
        super.onStart()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            registerScreenCaptureCallback(mainExecutor, onCapture as Activity.ScreenCaptureCallback)
        }
    }

    override fun onStop() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            unregisterScreenCaptureCallback(onCapture as Activity.ScreenCaptureCallback)
        }
        super.onStop()
    }
}
