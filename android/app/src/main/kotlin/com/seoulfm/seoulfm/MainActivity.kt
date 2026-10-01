package com.seoulfm.seoulfm

import com.ryanheise.audioservice.AudioServiceActivity

// AudioServiceActivity shares one Flutter engine between the screen and the playback
// service, so Android Auto and the notification drive the same player as the app.
class MainActivity : AudioServiceActivity()
