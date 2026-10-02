package com.seoulfm.seoulfm

import android.content.ComponentName
import android.content.Context
import android.graphics.drawable.Icon
import android.media.MediaMetadata
import android.media.browse.MediaBrowser
import android.media.session.MediaController
import android.media.session.PlaybackState
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.engine.FlutterEngineCache

/**
 * The Quick Settings tile: plays and pauses the radio, lit while it plays, with the station
 * underneath (Android 10+). It talks to audio_service's media session like any controller, so
 * the one player in the audio service does the work.
 *
 * While the app runs the tile follows the session. When it doesn't, the tile shows the last
 * station (what the home-screen widget was last told) and a tap connects to the audio service,
 * which starts the Flutter engine and plays once Dart is up (audio_service queues the command).
 */
class RadioTileService : TileService() {
    private var browser: MediaBrowser? = null
    private var controller: MediaController? = null
    private var listening = false

    // Tapped before the session was reachable: play once connected.
    private var playOnConnect = false

    private val callback = object : MediaController.Callback() {
        override fun onPlaybackStateChanged(state: PlaybackState?) = render()

        override fun onMetadataChanged(metadata: MediaMetadata?) = render()

        override fun onSessionDestroyed() {
            disconnect()
            render()
        }
    }

    override fun onStartListening() {
        listening = true
        // Only follow a radio that is already up: opening the shade must not boot the app.
        if (radioRunning()) connect()
        render()
    }

    override fun onStopListening() {
        listening = false
        if (!playOnConnect) disconnect()
    }

    override fun onDestroy() {
        disconnect()
        super.onDestroy()
    }

    override fun onClick() {
        val c = controller
        if (c == null) {
            playOnConnect = true
            connect()
            return
        }
        if (wantsPlaying(c)) c.transportControls.pause() else c.transportControls.play()
    }

    /** The app's engine exists, so the audio service is up (its plugin keeps it bound). */
    private fun radioRunning() = FlutterEngineCache.getInstance().contains(AudioServicePlugin.getFlutterEngineId())

    private fun connect() {
        if (browser != null) return
        // Binding starts the audio service if it isn't running; it starts the Flutter engine.
        val b = MediaBrowser(this, ComponentName(this, AUDIO_SERVICE), object : MediaBrowser.ConnectionCallback() {
            override fun onConnected() {
                val b = browser ?: return
                val c = MediaController(this@RadioTileService, b.sessionToken)
                c.registerCallback(callback)
                controller = c
                if (playOnConnect) {
                    playOnConnect = false
                    c.transportControls.play()
                    if (!listening) disconnect()
                }
                render()
            }

            override fun onConnectionFailed() {
                playOnConnect = false
                disconnect()
                render()
            }

            override fun onConnectionSuspended() {
                disconnect()
                render()
            }
        }, null)
        browser = b
        b.connect()
    }

    private fun disconnect() {
        controller?.unregisterCallback(callback)
        controller = null
        browser?.disconnect()
        browser = null
    }

    private fun render() {
        val tile = qsTile ?: return
        val c = controller
        val playing = c != null && wantsPlaying(c)
        tile.state = if (playing) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = getString(R.string.tile_label)
        tile.icon = Icon.createWithResource(this, R.drawable.ic_stat_seoulfm)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = station(c)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            tile.stateDescription = getString(if (playing) R.string.tile_playing else R.string.tile_paused)
        }
        tile.updateTile()
    }

    /** The station: the session's album ("SeoulFM Ballad"), else the last one the app showed. */
    private fun station(c: MediaController?): String? {
        val name = c?.metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM)
            ?: getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE).getString("stationName", null)
        // Drop the bidi isolates the app wraps Latin names in for right-to-left languages.
        return name?.filterNot { it in '⁦'..'⁩' }?.ifBlank { null }
    }

    /** Whether the listener wants sound: playing, or loading the stream after play was pressed. */
    private fun wantsPlaying(c: MediaController) = when (c.playbackState?.state) {
        PlaybackState.STATE_PLAYING, PlaybackState.STATE_BUFFERING, PlaybackState.STATE_CONNECTING -> true
        else -> false
    }

    companion object {
        private const val AUDIO_SERVICE = "com.ryanheise.audioservice.AudioService"
        private const val WIDGET_PREFS = "seoulfm_widget"
    }
}
