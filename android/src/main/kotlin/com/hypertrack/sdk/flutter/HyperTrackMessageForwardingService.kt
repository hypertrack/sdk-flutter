package com.hypertrack.sdk.flutter

import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.hypertrack.sdk.HyperTrackMessagingService
import java.lang.reflect.Field


class HyperTrackMessageForwardingService : HyperTrackMessagingService() {

    private lateinit var services: List<FirebaseMessagingService>

    override fun onCreate() {
        super.onCreate()
        val filterIntent = Intent("com.google.firebase.MESSAGING_EVENT")
        val pushListenerServices = packageManager.queryIntentServices(
                filterIntent,
                PackageManager.GET_RESOLVED_FILTER
        )
        services = pushListenerServices
                .filter { it.serviceInfo.packageName == packageName }
                .filter { it.serviceInfo.name != javaClass.name }
                .map {
                    try {
                        val serviceClass = Class.forName(it.serviceInfo.name);
                        val serviceObject = serviceClass.newInstance();
                        injectContext(serviceObject)
                    } catch (e: Throwable) {
                        Log.w(TAG, "Cannot add service ${it.serviceInfo.name} to forwarding list")
                        null
                    }
                }
                .filterIsInstance<FirebaseMessagingService>()
        Log.d(TAG, "Created services list $services")

    }

    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        super.onMessageReceived(remoteMessage)
        Log.v(TAG, "onMessageReceived: $remoteMessage")
        services.forEach { service ->
            try {
                service.onMessageReceived(remoteMessage)
            } catch (t: Throwable) {
                Log.w(TAG, "Can't forward the message to ${service.javaClass.simpleName}")
            }

        }

    }

    override fun onNewToken(newToken: String?) {
        super.onNewToken(newToken)
        Log.v(TAG, "onNewToken: $newToken")
        services.forEach { service ->
            try {
                service.onNewToken(newToken)
            } catch (t: Throwable) {
                Log.w(TAG, "Can't forward push token to ${service.javaClass.simpleName}")
            }
        }
    }


    private fun injectContext(targetObject: Any): Any? {
        var field: Field?
        val fieldName = "mBase"
        field = try {
            targetObject.javaClass.getDeclaredField(fieldName)
        } catch (e: NoSuchFieldException) {
            null
        }
        var superClass: Class<*>? = targetObject.javaClass.superclass
        while (field == null && superClass != null) {
            try {
                field = superClass.getDeclaredField(fieldName)
            } catch (e: NoSuchFieldException) {
                superClass = superClass.superclass
            }
        }
        if (field == null) {
            return null
        }
        return try {
            field.setAccessible(true)
            field.set(targetObject, this)
            targetObject
        } catch (e: Throwable) {
            null
        }
    }

    companion object {const val TAG = "MsgForwardingService"}
}