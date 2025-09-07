package com.mindrena.mindrena

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)

        // Let Flutter handle the notification display
        // Do not show notification here to avoid duplicates
        // Flutter's FirebaseMessaging.onMessage listener will handle it
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        // Send the token to your server
        sendRegistrationToServer(token)
    }

    private fun sendRegistrationToServer(token: String?) {
        // TODO: Implement this method to send token to your app server.
        // This is where you would send the FCM token to your backend
    }
}
