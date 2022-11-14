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
import com.hypertrack.sdk.flutter.common.Serialization.serializeErrors
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsAvailable
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsTracking

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
        invokeSdkMethod(call).sendAsFlutterResult(call, result)
    }

    private fun invokeSdkMethod(
        call: MethodCall
    ): Result<*> {
        val method = SdkMethod.values().firstOrNull { it.name == call.method } ?: run {
            return Success(NotImplemented)
        }
        return when (method) {
            SdkMethod.initialize -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.initialize(args).mapSuccess {
                        Unit
                    }
                }
            }
            SdkMethod.getDeviceId -> {
                HyperTrackSdkWrapper.getDeviceID()
            }
            SdkMethod.isTracking -> {
                HyperTrackSdkWrapper.isTracking()
            }
            SdkMethod.isAvailable -> {
                HyperTrackSdkWrapper.isAvailable()
            }
            SdkMethod.setAvailability -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setAvailability(args)
                }
            }
            SdkMethod.getLocation -> {
                HyperTrackSdkWrapper.getLocation()
            }
            SdkMethod.startTracking -> {
                HyperTrackSdkWrapper.startTracking()
            }
            SdkMethod.stopTracking -> {
                HyperTrackSdkWrapper.stopTracking()
            }
            SdkMethod.addGeotag -> {
                withArgs<Map<String, Any?>>(call) { args ->
                    HyperTrackSdkWrapper.addGeotag(args)
                }
            }
            SdkMethod.setName -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setName(args)
                }
            }
            SdkMethod.setMetadata -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setMetadata(args)
                }
            }
            SdkMethod.sync -> {
                HyperTrackSdkWrapper.sync()
            }
        }
    }

    private fun <N> withArgs(call: MethodCall, block: (Map<String, Any?>) -> Result<N>): Result<N> {
        return call.arguments<Map<String, Any?>>()?.let { block.invoke(it) }
            ?: Failure(NullPointerException(call.method))
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        trackingStateEventChannel = EventChannel(messenger, TRACKING_STATE_EVENT_CHANNEL_NAME)
        trackingStateEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                Result
                    .tryAsResult {
                        val sdk = HyperTrackSdkWrapper.sdkInstance
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
                        events.success(serializeIsTracking(sdk.isTracking))
                    }
                    .crashAppIfError()
            }

            override fun onCancel(arguments: Any?) {
                HyperTrackSdkWrapper.sdkInstance.let { sdk ->
                    sdk.removeTrackingListener(trackingStateListener)
                    trackingStateListener = null
                }
            }
        })

        errorEventChannel = EventChannel(messenger, ERROR_EVENT_CHANNEL_NAME)
        errorEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                Result
                    .tryAsResult {
                        val sdk = HyperTrackSdkWrapper.sdkInstance
                        errorChannelTrackingStateListener =
                            object : TrackingStateObserver.OnTrackingStateChangeListener {
                                override fun onTrackingStart() {
                                    // ignored, trackingState is handled by trackingStateEventChannel
                                }

                                override fun onTrackingStop() {
                                    // ignored, trackingState is handled by trackingStateEventChannel
                                }

                                override fun onError(error: TrackingError) {
                                    events.success(HyperTrackSdkWrapper.getErrors(error))
                                }
                            }
                        sdk.addTrackingListener(errorChannelTrackingStateListener)
                        events.success(HyperTrackSdkWrapper.getInitialErrors())
                    }
                    .crashAppIfError()
            }

            override fun onCancel(arguments: Any?) {
                HyperTrackSdkWrapper.sdkInstance.let { sdk ->
                    sdk.removeTrackingListener(errorChannelTrackingStateListener)
                    errorChannelTrackingStateListener = null
                }
            }
        })

        availabilityEventChannel = EventChannel(messenger, AVAILABILTY_EVENT_CHANNEL_NAME)
        availabilityEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink) {
                    Result
                        .tryAsResult {
                            val sdk = HyperTrackSdkWrapper.sdkInstance
                            availabilityListener =
                                object :
                                    AvailabilityStateObserver.OnAvailabilityStateChangeListener {
                                    override fun onError(p0: AvailabilityError) {
                                        // ignored, errors are handled by errorEventChannel
                                    }

                                    override fun onAvailable() {
                                        events.success(serializeIsAvailable(true))
                                    }

                                    override fun onUnavailable() {
                                        events.success(serializeIsAvailable(false))
                                    }
                                }
                            sdk.addAvailabilityListener(availabilityListener)
                            events.success(serializeIsAvailable(sdk.availability.equals(Availability.AVAILABLE)))
                        }
                        .crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    HyperTrackSdkWrapper.sdkInstance.let { sdk ->
                        sdk.removeAvailabilityListener(availabilityListener)
                        availabilityListener = null
                    }
                }
            })
    }

    companion object {
        private const val METHOD_CHANNEL_NAME = "sdk.hypertrack.com/methods"
        private const val TRACKING_STATE_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/tracking"
        private const val ERROR_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/errors"
        private const val AVAILABILTY_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/availability"

        internal const val ERROR_CODE_METHOD_CALL = "method_call_error"
    }
}

