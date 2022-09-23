package com.hypertrack.sdk.flutter


import android.content.Context
import android.location.Location
import android.util.Log
import androidx.annotation.NonNull
import com.hypertrack.sdk.*
import com.hypertrack.sdk.HyperTrack.getBlockers
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
import java.util.*

public class HyperTrackPlugin : FlutterPlugin, MethodCallHandler {

    // receives method calls from the plugin API
    private var methodChannel: MethodChannel? = null

    // send events from the SDK to plugin clients
    private var trackingStateEventChannel: EventChannel? = null
    private var availabilityEventChannel: EventChannel? = null

    private var sdkInstance: HyperTrack? = null

    private var trackingStateListener: TrackingStateObserver.OnTrackingStateChangeListener? = null
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
            "initialize" -> {
                try {
                    call.arguments<String>()?.let { publishableKey ->
                        sdkInstance = HyperTrack.getInstance(publishableKey)
                        result.success(null)
                    } ?: run {
                        result.error(
                            "INIT_ERROR",
                            "onMethodCall(${call.method}) - Publishable key can't be null",
                            null
                        )
                    }
                } catch (e: Exception) {
                    result.error("INIT_ERROR", e.message, e)
                }
            }
            "enableDebugLogging" -> {
                HyperTrack.enableDebugLogging()
            }
            "getDeviceId" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.deviceID)
                }
            }
            "isRunning" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.isRunning)
                }
            }
            "isTracking" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.isTracking)
                }
            }
            "getAvailability" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.availability.toString())
                }
            }
            "setAvailability" -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Boolean>()?.let { arguments ->
                        setAvailability(result, sdk, arguments)
                    } ?: run {
                        result.error(
                            "INVALID_ARGS",
                            "Internal Error: onMethodCall(${call.method}) - arguments is null",
                            null
                        )
                    }
                }
            }
            "getLatestLocation" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.latestLocation)
                }
            }
            "start" -> {
                withSdkInstance(call, result) { sdk ->
                    start(result, sdk)
                }
            }
            "stop" -> {
                withSdkInstance(call, result) { sdk ->
                    sdk.stop()
                    result.success(null)
                }
            }
            "addGeotag" -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Map<String, Any>>()?.let { arguments ->
                        addGeotag(arguments, result, sdk)
                    } ?: run {
                        result.error(
                            "INVALID_ARGS",
                            "Internal Error: onMethodCall(${call.method}) - arguments is null",
                            null
                        )
                    }
                }
            }
            "allowMockLocations" -> {
                withSdkInstance(call, result) { sdk ->
                    sdk.allowMockLocations()
                    result.success(null)
                }
            }
            "setDeviceName" -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<String>()?.let { name ->
                        sdk.setDeviceName(name)
                        result.success(null)
                    }
                        ?: result.error(
                            "INVALID_ARGS",
                            "Internal Error: onMethodCall(${call.method}) - arguments is null",
                            null
                        )
                }
            }
            "setDeviceMetadata" -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Map<String, Any>?>()?.let { data ->
                        sdk.setDeviceMetadata(data)
                        result.success(null)
                    } ?: run {
                        result.error(
                            "INVALID_ARGS",
                            "Internal Error: onMethodCall(${call.method}) - arguments is null",
                            null
                        )
                    }
                }
            }
            "syncDeviceSettings" -> {
                withSdkInstance(call, result) { sdk ->
                    sdk.syncDeviceSettings()
                    result.success(null)
                }
            }
            "getBlockers" -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(HyperTrack.getBlockers().toString())
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun withSdkInstance(
        call: MethodCall,
        result: MethodChannel.Result,
        onInstanceCall: (sdk: HyperTrack) -> Unit
    ) {
        sdkInstance.let { instance ->
            if (instance == null) {
                result.error(
                    "NOT_INITIALIZED",
                    "Internal Error: onMethodCall(${call.method}) - sdkInstance is null",
                    null
                )
                return
            } else {
                onInstanceCall(instance)
            }
        }
    }

    private fun start(result: MethodChannel.Result, sdk: HyperTrack) {
        val listener = object : TrackingStateObserver.OnTrackingStateChangeListener {
            override fun onTrackingStart() {
                result.success(null)
                sdk.removeTrackingListener(this)
            }

            override fun onError(p0: TrackingError) {
                result.error("Start failed", p0.message, null)
                sdk.removeTrackingListener(this)
            }

            override fun onTrackingStop() {
            }
        }
        sdk.addTrackingListener(listener).start()
    }

    private fun addGeotag(
        options: Map<String, Any>,
        result: MethodChannel.Result,
        sdk: HyperTrack
    ) {
        val data = options["data"] as Map<String, Serializable>?
        data?.let {
            val expectedLocation: Location? =
                (options["expectedLocation"] as Map<String, Any>?)?.let { params ->
                    val lat = params["latitude"] as Double
                    val lng = params["longitude"] as Double
                    Location("any").apply {
                        latitude = lat
                        longitude = lng
                    }
                }
            when (val geotagResult = sdk.addGeotag(data, expectedLocation)) {
                is GeotagResult.SuccessWithDeviation -> result.success("""{"result": "success", "distance": ${geotagResult.deviationDistance}}""")
                is GeotagResult.Success -> result.success("""{"result": "success"}""")
                is GeotagResult.Error -> result.success("""{"result": "error", "reason": "${geotagResult.reason}"}""")
            }
        } ?: result.error("GEOTAG_ERROR", "No geotag data provided", null)
    }

    private fun setAvailability(result: MethodChannel.Result, sdk: HyperTrack, arguments: Boolean) {
        if (arguments == true) {
            sdk.setAvailability(Availability.AVAILABLE)
        } else if (arguments == false) {
            sdk.setAvailability(Availability.UNAVAILABLE)
            result.success(null)
        }
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        trackingStateEventChannel = EventChannel(messenger, TRACKING_STATE_EVENT_CHANNEL_NAME)
        trackingStateEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                sdkInstance?.let { sdk ->
                    trackingStateListener = object : TrackingStateObserver.OnTrackingStateChangeListener {
                        override fun onTrackingStart() {
                            events.success("start")
                        }

                        override fun onError(p0: TrackingError?) {
                            when (p0?.code) {
                                TrackingError.INVALID_PUBLISHABLE_KEY_ERROR -> events.success("publishable_key_error")
                                TrackingError.PERMISSION_DENIED_ERROR -> events.success("permissions_denied")
                                TrackingError.AUTHORIZATION_ERROR -> events.success("auth_error")
                                TrackingError.GPS_PROVIDER_DISABLED_ERROR -> events.success("gps_disabled")
                                TrackingError.UNKNOWN_NETWORK_ERROR -> events.success("network_error")
                                else -> events.success(p0?.message ?: "unknown error")
                            }
                        }

                        override fun onTrackingStop() {
                            events.success("stop")
                        }
                    }
                    sdk.addTrackingListener(trackingStateListener)
                } ?: run {
                    events.error("INVALID_STATE", "Unable to create stream before SDK init", null)
                }
            }

            override fun onCancel(arguments: Any?) {
                sdkInstance?.removeTrackingListener(trackingStateListener)
                trackingStateListener = null
            }
        })

        availabilityEventChannel = EventChannel(messenger, AVAILABILTY_EVENT_CHANNEL_NAME)
        availabilityEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                sdkInstance?.let { sdk ->
                    availabilityListener =
                        object : AvailabilityStateObserver.OnAvailabilityStateChangeListener {
                            override fun onError(p0: AvailabilityError) {
                                events.error("AVAILABILITY_ERROR", p0.name, null)
                            }

                            override fun onAvailable() {
                                events.success(true)
                            }

                            override fun onUnavailable() {
                                events.success(false)
                            }
                        }
                    sdk.addAvailabilityListener(availabilityListener)
                } ?: run {
                    events.error("INVALID_STATE", "Unable to create stream before SDK init", null)
                }
            }

            override fun onCancel(arguments: Any?) {
                sdkInstance?.removeAvailabilityListener(availabilityListener)
                availabilityListener = null
            }
        })
    }

    companion object {
        private val TAG = javaClass.simpleName
        private const val METHOD_CHANNEL_NAME = "sdk.hypertrack.com/handle"
        private const val TRACKING_STATE_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/trackingState"
        private const val AVAILABILTY_EVENT_CHANNEL_NAME =
            "sdk.hypertrack.com/availabilitySubscription"
    }
}

