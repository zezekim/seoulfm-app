package com.seoulfm.seoulfm

import android.app.Activity
import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.drawable.Icon
import android.media.MediaRouter2
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
        val app = applicationContext
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fm.seoul/widgets").setMethodCallHandler { call, result ->
            if (call.method == "update" && call.arguments is Map<*, *>) {
                NowPlayingWidget.update(app, call.arguments as Map<*, *>)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fm.seoul/output").setMethodCallHandler { call, result ->
            if (call.method == "pick") {
                showOutputSwitcher()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fm.seoul/tile").setMethodCallHandler { call, result ->
            when (call.method) {
                // The system's "add tile" prompt is Android 13+; earlier, the listener adds it by editing the panel.
                "canAdd" -> result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                "add" -> requestAddTile(result)
                else -> result.notImplemented()
            }
        }
    }

    // Asks the system to add the Quick Settings tile; answers with StatusBarManager's result code.
    private fun requestAddTile(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return result.success(null)
        getSystemService(StatusBarManager::class.java).requestAddTileService(
            ComponentName(this, RadioTileService::class.java),
            getString(R.string.tile_label),
            Icon.createWithResource(this, R.drawable.ic_stat_seoulfm),
            mainExecutor,
        ) { code -> result.success(code) }
    }

    // Where the sound goes: Android 14's system output switcher, else the media output panel.
    private fun showOutputSwitcher() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            MediaRouter2.getInstance(this).showSystemOutputSwitcher()
        ) {
            return
        }
        try {
            startActivity(
                Intent("com.android.settings.panel.action.MEDIA_OUTPUT")
                    .putExtra("com.android.settings.panel.extra.PACKAGE_NAME", packageName)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
        } catch (_: Exception) {
        }
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
