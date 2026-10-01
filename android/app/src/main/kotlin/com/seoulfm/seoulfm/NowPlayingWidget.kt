package com.seoulfm.seoulfm

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.view.KeyEvent
import android.widget.RemoteViews
import java.io.File
import java.net.URL
import kotlin.concurrent.thread

/**
 * The home-screen widget: what the app last told it is on air (`HomeWidgets` in Dart), the
 * cover, and a play/pause button that sends the same media key a headset would, so it drives
 * the one player in the audio service. Tapping elsewhere opens the app.
 */
class NowPlayingWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        render(context, manager, ids)
    }

    companion object {
        private const val PREFS = "seoulfm_widget"
        private const val ART = "widget_art.png"

        /** Stores what the app sent, fetches the cover off the main thread, then redraws. */
        fun update(context: Context, data: Map<*, *>) {
            val app = context.applicationContext
            val prefs = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val artUrl = data["artUrl"] as? String
            val artChanged = artUrl != prefs.getString("artUrl", null)
            prefs.edit()
                .putString("stationName", data["stationName"] as? String)
                .putString("title", data["title"] as? String)
                .putString("artist", data["artist"] as? String)
                .putString("artUrl", artUrl)
                .putInt("accent", (data["accent"] as? Number)?.toInt() ?: 0xFFFF3B5C.toInt())
                .putBoolean("playing", data["playing"] == true)
                .apply()
            refresh(app)
            if (artChanged) {
                thread {
                    val file = File(app.filesDir, ART)
                    try {
                        if (artUrl == null) {
                            file.delete()
                        } else {
                            val bytes = URL(artUrl).openStream().use { it.readBytes() }
                            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return@thread
                            // Widgets travel between processes: keep the bitmap small.
                            val scaled = Bitmap.createScaledBitmap(bitmap, 256, 256, true)
                            file.outputStream().use { scaled.compress(Bitmap.CompressFormat.PNG, 100, it) }
                        }
                        refresh(app)
                    } catch (_: Exception) {
                    }
                }
            }
        }

        private fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, NowPlayingWidget::class.java))
            if (ids.isNotEmpty()) render(context, manager, ids)
        }

        private fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.widget_now_playing)
            val title = prefs.getString("title", null)
            views.setTextViewText(R.id.widget_station, prefs.getString("stationName", null) ?: "SeoulFM")
            views.setTextColor(R.id.widget_station, prefs.getInt("accent", 0xFFFF3B5C.toInt()) or 0xFF000000.toInt())
            views.setTextViewText(R.id.widget_title, title ?: context.getString(R.string.widget_idle))
            views.setTextViewText(R.id.widget_artist, prefs.getString("artist", null) ?: "")

            val art = File(context.filesDir, ART)
            val bitmap = if (art.exists()) BitmapFactory.decodeFile(art.path) else null
            if (bitmap != null) views.setImageViewBitmap(R.id.widget_art, bitmap) else views.setImageViewResource(R.id.widget_art, R.mipmap.ic_launcher)

            val playing = prefs.getBoolean("playing", false)
            views.setImageViewResource(R.id.widget_play, if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play)

            // Play/pause: the headset key, to audio_service's media button receiver.
            val key = Intent(Intent.ACTION_MEDIA_BUTTON)
                .setComponent(ComponentName(context, "com.ryanheise.audioservice.MediaButtonReceiver"))
                .putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE))
            views.setOnClickPendingIntent(
                R.id.widget_play,
                PendingIntent.getBroadcast(context, 1, key, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT),
            )
            val open = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            views.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(context, 2, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT),
            )
            manager.updateAppWidget(ids, views)
        }
    }
}
