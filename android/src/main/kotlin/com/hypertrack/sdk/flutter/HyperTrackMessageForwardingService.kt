package com.hypertrack.sdk.flutter

import android.content.Intent
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.google.firebase.messaging.RemoteMessage
import com.hypertrack.sdk.HyperTrackMessagingService


class HyperTrackMessageForwardingService : HyperTrackMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        super.onMessageReceived(remoteMessage)
        Log.d(TAG, "onMessageReceived: $remoteMessage")
        try {
            val target = Class.forName("io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver")
            val intent = Intent(applicationContext, target)
            intent.putExtras(remoteMessage?.toIntent()?:return)
            sendBroadcast(intent)
        } catch (t: Throwable) {
            Log.d(TAG, "Can't get target to forward the message: $t")
        }
        
    }

    override fun onNewToken(newToken: String?) {
        super.onNewToken(newToken)
        Log.d(TAG, "onNewToken: $newToken")
        val onMessageIntent = Intent("io.flutter.plugins.firebase.messaging.TOKEN")
        onMessageIntent.putExtra("token", newToken)
        LocalBroadcastManager.getInstance(applicationContext).sendBroadcast(onMessageIntent)
    }

    companion object {const val TAG = "MsgForwardingService"}
}