package com.hypertrack.sdk.flutter


import android.content.Context
import android.location.Location
import android.util.Log
import androidx.annotation.NonNull
import com.hypertrack.sdk.flutter.common.*
import com.hypertrack.sdk.flutter.common.Result
import com.hypertrack.sdk.flutter.common.Success
import com.hypertrack.sdk.*
import com.hypertrack.sdk.GeotagResult.Error.Reason
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.Serializable
import java.lang.IllegalStateException
import java.lang.NullPointerException
import java.lang.RuntimeException
import java.util.*

public class HyperTrackPlugin : FlutterPlugin, MethodCallHandler {

    // receives method calls from the plugin API
    private var methodChannel: MethodChannel? = null

    // send events from the SDK to plugin clients
    private var trackingStateEventChannel: EventChannel? = null
    private var availabilityEventChannel: EventChannel? = null
    private var errorEventChannel: EventChannel? = null

    private var trackingStateListener: TrackingStateObserver.OnTrackingStateChangeListener? = null
    private var errorChannelTrackingStateListener: TrackingStateObserver.OnTrackingStateChangeListener? =
        null
    private var availabilityListener: AvailabilityStateObserver.OnAvailabilityStateChangeListener? =
        null;

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        initEventChannels(messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        trackingStateEventChannel?.setStreamHandler(null)
        trackingStateEventChannel = null
        availabilityEventChannel?.setStreamHandler(null)
        availabilityEventChannel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        /**
         * we use withSdkInstance() to be able to check if the method is unknown
         * before checking if instance is present
         * for case if the unknown method is called before the init
         */
        when (call.method) {
            SdkMethod.initialize.name -> {
                withArgs<Map<String, Any>, Unit>(call) { args ->
                    val publishableKey = args.getValue(KEY_PUBLISHABLE_KEY) as String
                    val initParams = SdkInitParams.fromMap(args.filter {
                        it.value is Boolean
                    }.mapValues {
                        it.value is Boolean
                    })

                    HyperTrackSdkWrapper.initialize(
                        publishableKey,
                        initParams
                    )
                    Success(Unit)
                }.toFlutterResult(call, result)
            }
            SdkMethod.getDeviceId.name -> {
                HyperTrackSdkWrapper.getDeviceID()
                    .toFlutterResult(call, result)
            }
            SdkMethod.isTracking.name -> {
                HyperTrackSdkWrapper.isTracking()
                    .toFlutterResult(call, result)
            }
            SdkMethod.isAvailable.name -> {
                HyperTrackSdkWrapper.isAvailable()
                    .toFlutterResult(call, result)
            }
            SdkMethod.setAvailability.name -> {
                withArgs<Map<String,Boolean>, Unit>(call) { args ->
                    HyperTrackSdkWrapper.setAvailability(args)
                    Success(Unit)
                }.toFlutterResult(call, result)
            }
            SdkMethod.getLocation.name -> {
                HyperTrackSdkWrapper.getLocation()
                    .toFlutterResult(call, result)
            }
            SdkMethod.startTracking.name -> {
                HyperTrackSdkWrapper.startTracking()
                    .toFlutterResult(call, result)
            }
            SdkMethod.stopTracking.name -> {
                HyperTrackSdkWrapper.stopTracking()
                    .toFlutterResult(call, result)
            }
            SdkMethod.addGeotag.name -> {
                withArgs<Map<String, Any>, Map<String, Any>>(call) { args ->
                    HyperTrackSdkWrapper.addGeotag(args)
                }.toFlutterResult(call, result)
            }
            SdkMethod.setName.name -> {
                withArgs<String, Unit>(call) { args ->
                    HyperTrackSdkWrapper.setName(args)
                    Success(Unit)
                }.toFlutterResult(call, result)
            }
            SdkMethod.setMetadata.name -> {
                withArgs<Map<String, Any>, Unit>(call) { args ->
                    HyperTrackSdkWrapper.setMetadata(args)
                    Success(Unit)
                }.toFlutterResult(call, result)
            }
            SdkMethod.sync.name -> {
                HyperTrackSdkWrapper.sync()
                    .toFlutterResult(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun <T, N> withArgs(call: MethodCall, block: (T) -> Result<N>): Result<N> {
        return call.arguments<T>()?.let { block.invoke(it) }
            ?: Failure(NullPointerException(call.method))
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        trackingStateEventChannel = EventChannel(messenger, TRACKING_STATE_EVENT_CHANNEL_NAME)
        trackingStateEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                HyperTrackSdkWrapper.withSdkInstance { sdk ->
                    trackingStateListener =
                        object : TrackingStateObserver.OnTrackingStateChangeListener {
                            override fun onTrackingStart() {
                                events.success(serializeIsTracking(true))
                            }

                            override fun onTrackingStop() {
                                events.success(serializeIsTracking(false))
                            }

                            override fun onError(p0: TrackingError) {
                                // ignored, errors are handled by errorEventChannel
                            }
                        }
                    sdk.addTrackingListener(trackingStateListener)
                }.sendEventIfError(events, ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT)
            }

            override fun onCancel(arguments: Any?) {
                HyperTrackSdkWrapper.withSdkInstance { sdk ->
                    sdk.removeTrackingListener(trackingStateListener)
                    trackingStateListener = null
                }
            }
        })

        errorEventChannel = EventChannel(messenger, ERROR_EVENT_CHANNEL_NAME)
        errorEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                HyperTrackSdkWrapper.withSdkInstance { sdk ->
                    errorChannelTrackingStateListener =
                        object : TrackingStateObserver.OnTrackingStateChangeListener {
                            override fun onTrackingStart() {
                                // ignored, trackingState is handled by trackingStateEventChannel
                            }

                            override fun onTrackingStop() {
                                // ignored, trackingState is handled by trackingStateEventChannel
                            }

                            override fun onError(error: TrackingError) {
                                events.success(
                                    serializeErrors(
                                        HyperTrackSdkWrapper.getTrackingErrors(error)
                                    )
                                )
                            }
                        }
                    sdk.addTrackingListener(errorChannelTrackingStateListener)
                }.sendEventIfError(events, ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT)
            }

            override fun onCancel(arguments: Any?) {
                HyperTrackSdkWrapper.withSdkInstance { sdk ->
                    sdk.removeTrackingListener(errorChannelTrackingStateListener)
                    errorChannelTrackingStateListener = null
                }
            }
        })

        availabilityEventChannel = EventChannel(messenger, AVAILABILTY_EVENT_CHANNEL_NAME)
        availabilityEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink) {
                    HyperTrackSdkWrapper.withSdkInstance { sdk ->
                        availabilityListener =
                            object : AvailabilityStateObserver.OnAvailabilityStateChangeListener {
                                override fun onError(p0: AvailabilityError) {
                                    // ignored, errors are handled by errorEventChannel
                                }

                                override fun onAvailable() {
                                    events.success(serializeAvailability(true))
                                }

                                override fun onUnavailable() {
                                    events.success(serializeAvailability(false))
                                }
                            }
                        sdk.addAvailabilityListener(availabilityListener)
                    }.sendEventIfError(events, ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT)
                }

                override fun onCancel(arguments: Any?) {
                    HyperTrackSdkWrapper.withSdkInstance { sdk ->
                        sdk.removeAvailabilityListener(availabilityListener)
                        availabilityListener = null
                    }
                }
            })
    }

    companion object {
        private const val METHOD_CHANNEL_NAME = "sdk.hypertrack.com/methods"
        private const val TRACKING_STATE_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/trackingState"
        private const val ERROR_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/trackingError"
        private const val AVAILABILTY_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/availability"

        private const val KEY_PUBLISHABLE_KEY = "publishableKey"

        private const val ERROR_CODE_STREAM_INIT = "stream_init_error"
        private const val ERROR_MESSAGE_STREAM_INIT = "Unable to create stream before SDK init"
    }
}

