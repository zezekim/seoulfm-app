# Push notifications for song requests (brief for the API team)

## Why

When a listener requests a song in the iOS or Android app, the app follows it on
`GET /v3/requests/{request_id}/events?token={status_token}` (SSE, `request_status` events) and
shows a local notification when the request is coming up and when it is on air. That only works
while the app's process is alive. iOS suspends an app in the background unless it is playing
audio, and both systems kill idle apps. So a listener who requests a song and then pauses or
leaves the app never hears that their song is on. Real push (APNs for iOS, FCM for Android),
sent by the API when the request's status changes, fixes that.

## What we are asking for

### 1. Register a device for one request

```
POST /v3/requests/{request_id}/push
Content-Type: application/json
X-Api-Key: <publishable app key>

{
  "token": "<status_token from POST /v3/requests>",
  "platform": "ios" | "android",
  "push_token": "<APNs device token (hex) or FCM registration token>",
  "environment": "production" | "sandbox",   // iOS only: which APNs host to use
  "locale": "ko-KR",                          // for the notification text
  "events": ["scheduled", "playing"]          // optional; this is the default
}
```

- Authorised by the request's `status_token`, like the SSE stream: no account and no new
  identity. The push token is bound to that one request, not to the listener.
- Responses: `204` registered (idempotent: the same push token again is a no-op); `403` wrong
  token; `404` unknown request; `409` the request is already final (played, expired, rejected,
  cancelled), in which case the app shows the result itself; `429` with `retry_after_seconds`.
- `DELETE /v3/requests/{request_id}/push?token=...&push_token=...` unregisters (the listener
  turned notifications off, or cancelled the request).
- Keep the registration until the request is final, then delete it. Store nothing else about the
  device. Drop push tokens that APNs answers `410 Unregistered` or FCM answers `UNREGISTERED`.

### 2. Send on status changes

Send at most one push per moment per request:

| Status change          | When                                | Text (localised, like the app's)            |
| ---------------------- | ----------------------------------- | ------------------------------------------- |
| `scheduled`            | first time it gets a slot           | "“{title}” is coming up" + "Plays in about {n} min" |
| `playing` (or `played` if `playing` was never sent) | when it goes on air | "“{title}” is on air now" + artist |

No pushes for `queued` (the listener just saw that in the app) or for later ETA updates. Expired
or rejected requests may send one quiet push with the API's `status_reason`; that is optional.

If the app strings are needed server side, the English and Korean ones are `requestScheduled`,
`etaMinutes`, `etaSoon` and `requestPlayed` in `lib/l10n/app_en.arb` and `app_ko.arb`; all 20
languages are in the same folder.

### 3. Payload

APNs (`apns-push-type: alert`, `apns-priority: 10`, `apns-collapse-id: {request_id}`,
`apns-expiration` a few minutes after the ETA so a stale "coming up" isn't delivered late):

```json
{
  "aps": {
    "alert": { "title": "“Supernova” is on air now", "body": "aespa" },
    "sound": "default",
    "thread-id": "requests",
    "interruption-level": "active"
  },
  "request_id": "req_…",
  "status": "playing",
  "station": "pop",
  "eta_minutes": null
}
```

FCM HTTP v1 (`android.priority: HIGH`, `android.collapse_key: {request_id}`, `android.ttl`
as above), a notification message on the app's channel:

```json
{
  "message": {
    "token": "<fcm token>",
    "notification": { "title": "“Supernova” is on air now", "body": "aespa" },
    "android": {
      "priority": "HIGH",
      "collapse_key": "req_…",
      "notification": { "channel_id": "com.seoulfm.seoulfm.requests", "icon": "ic_stat_seoulfm", "tag": "req_…" }
    },
    "data": { "request_id": "req_…", "status": "playing", "station": "pop" }
  }
}
```

`tag` / `collapse-id` = the request id, so "on air" replaces "coming up" on the lock screen, as
the app's local notifications already do.

### 4. Credentials

- APNs: a token-based auth key (.p8) for the team that owns `com.seoulfm.seoulfm`, topic
  `com.seoulfm.seoulfm`. Sandbox for development builds, production for TestFlight and the store.
- FCM: a Firebase project for `com.seoulfm.seoulfm` and a service account for the HTTP v1 API.

## App changes this needs (for the app team, once the endpoint exists)

1. Add `firebase_messaging` (Android token and delivery) and the APNs device token on iOS
   (`firebase_messaging` can provide both, or a small platform channel for APNs). Add
   `google-services.json` for Android; on iOS turn on the Push Notifications capability and the
   `aps-environment` entitlement.
2. After an accepted request, if notification permission is granted (the app already asks at
   exactly this moment), `POST /v3/requests/{id}/push` with the token. Re-register if the push
   token rotates while the request is open.
3. Avoid doubles: while the app is alive and following the SSE stream, it already notifies
   locally. Either stop local notifications when a push registration succeeded, or keep them
   and rely on the shared id (`request_id`) so the system replaces one with the other. On iOS,
   suppress the push while the app is in the foreground (the in-app toast covers it).
4. Tapping a push opens the full-screen player, like the local notification does
   (`RequestNotifications.opened`).
5. Privacy: the push token is sent to our API and used only for that request's status; say so in
   the privacy notes and the App Store / Play data safety forms.
