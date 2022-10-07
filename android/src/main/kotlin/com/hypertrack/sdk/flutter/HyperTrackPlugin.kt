package com.hypertrack.sdk.flutter


import android.content.Context
import android.location.Location
import android.util.Log
import androidx.annotation.NonNull
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
import java.lang.RuntimeException
import java.util.*

public class HyperTrackPlugin : FlutterPlugin, MethodCallHandler {

    // receives method calls from the plugin API
    private var methodChannel: MethodChannel? = null

    // send events from the SDK to plugin clients
    private var trackingStateEventChannel: EventChannel? = null
    private var availabilityEventChannel: EventChannel? = null
    private var errorEventChannel: EventChannel? = null

    private var sdkInstance: HyperTrack? = null

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
                try {
                    call.arguments<String>()?.let { publishableKey ->
                        sdkInstance = HyperTrack.getInstance(publishableKey)
                        result.success(null)
                    } ?: run {
                        result.error(
                            ERROR_CODE_METHOD_CALL,
                            "onMethodCall(${call.method}) - Publishable key can't be null",
                            null
                        )
                    }
                } catch (e: Exception) {
                    result.error(ERROR_CODE_INIT, e.toString(), null)
                }
            }
            SdkMethod.enableDebugLogging.name -> {
                // boolean param for this method is ignored because of
                // Hypertrack SDK Android API discrepancies
                HyperTrack.enableDebugLogging()
            }
            SdkMethod.getDeviceId.name -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(sdk.deviceID)
                }
            }
            SdkMethod.isTracking.name -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(serializeIsTracking(sdk.isTracking))
                }
            }
            SdkMethod.getAvailability.name -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(
                        serializeAvailability(
                            when (sdk.availability) {
                                Availability.AVAILABLE -> true
                                Availability.UNAVAILABLE -> false
                            }
                        )
                    )
                }
            }
            SdkMethod.setAvailability.name -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Map<String, Boolean>>()
                        ?.get(KEY_AVAILABILITY)
                        ?.let { isAvailable ->
                            setAvailability(result, sdk, isAvailable)
                        } ?: run {
                        result.error(
                            ERROR_CODE_METHOD_CALL,
                            "onMethodCall(${call.method}) - invalid availability data: ${call.arguments<Any>()}",
                            null
                        )
                    }

                }
            }
            SdkMethod.getLocation.name -> {
                withSdkInstance(call, result) { sdk ->
                    result.success(serializeLocationResponse(sdk.latestLocation))
                }
            }
            SdkMethod.startTracking.name -> {
                withSdkInstance(call, result) { sdk ->
                    start(result, sdk)
                }
            }
            SdkMethod.stopTracking.name -> {
                withSdkInstance(call, result) { sdk ->
                    sdk.stop()
                    result.success(null)
                }
            }
            SdkMethod.addGeotag.name -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Map<String, Any>>()?.let { arguments ->
                        addGeotag(arguments, result, sdk)
                    } ?: run {
                        result.error(
                            ERROR_CODE_METHOD_CALL,
                            "onMethodCall(${call.method}) - arguments value is null",
                            null
                        )
                    }
                }
            }
            SdkMethod.allowMockLocations.name -> {
                withSdkInstance(call, result) { sdk ->
                    // boolean param for this method is ignored because of
                    // Hypertrack SDK Android API discrepancies
                    sdk.allowMockLocations()
                    result.success(null)
                }
            }
            SdkMethod.setName.name -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<String>()?.let { name ->
                        sdk.setDeviceName(name)
                        result.success(null)
                    } ?: result.error(
                        ERROR_CODE_METHOD_CALL,
                        "onMethodCall(${call.method}) - arguments value is null",
                        null
                    )
                }
            }
            SdkMethod.setMetadata.name -> {
                withSdkInstance(call, result) { sdk ->
                    call.arguments<Map<String, Any>?>()?.let { data ->
                        sdk.setDeviceMetadata(data)
                        result.success(null)
                    } ?: run {
                        result.error(
                            ERROR_CODE_METHOD_CALL,
                            "onMethodCall(${call.method}) - arguments value is null",
                            null
                        )
                    }
                }
            }
            SdkMethod.sync.name -> {
                withSdkInstance(call, result) { sdk ->
                    sdk.syncDeviceSettings()
                    result.success(null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        trackingStateEventChannel = EventChannel(messenger, TRACKING_STATE_EVENT_CHANNEL_NAME)
        trackingStateEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                sdkInstance?.let { sdk ->
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
                } ?: run {
                    events.error(ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT, null)
                }
            }

            override fun onCancel(arguments: Any?) {
                sdkInstance?.removeTrackingListener(trackingStateListener)
                trackingStateListener = null
            }
        })

        errorEventChannel = EventChannel(messenger, ERROR_EVENT_CHANNEL_NAME)
        errorEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                sdkInstance?.let { sdk ->
                    errorChannelTrackingStateListener =
                        object : TrackingStateObserver.OnTrackingStateChangeListener {
                            override fun onTrackingStart() {
                                // ignored, trackingState is handled by trackingStateEventChannel
                            }

                            override fun onTrackingStop() {
                                // ignored, trackingState is handled by trackingStateEventChannel
                            }

                            override fun onError(error: TrackingError) {
                                events.success(getTrackingErrors(error).map {
                                    serializeHypertrackError(it)
                                })
                            }
                        }
                    sdk.addTrackingListener(errorChannelTrackingStateListener)
                } ?: run {
                    events.error(ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT, null)
                }
            }

            override fun onCancel(arguments: Any?) {
                sdkInstance?.removeTrackingListener(errorChannelTrackingStateListener)
                errorChannelTrackingStateListener = null
            }
        })

        availabilityEventChannel = EventChannel(messenger, AVAILABILTY_EVENT_CHANNEL_NAME)
        availabilityEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(arguments: Any?, events: EventSink) {
                    sdkInstance?.let { sdk ->
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
                    } ?: run {
                        events.error(ERROR_CODE_STREAM_INIT, ERROR_MESSAGE_STREAM_INIT, null)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    sdkInstance?.removeAvailabilityListener(availabilityListener)
                    availabilityListener = null
                }
            })
    }

    private fun withSdkInstance(
        call: MethodCall,
        result: MethodChannel.Result,
        onInstanceCall: (sdk: HyperTrack) -> Unit
    ) {
        sdkInstance.let { instance ->
            if (instance == null) {
                result.error(
                    ERROR_CODE_SDK_NOT_INITIALIZED,
                    "onMethodCall(${call.method}) - sdkInstance is null",
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
        val data = options[KEY_GEOTAG_DATA] as Map<String, Serializable>?
        Log.d(javaClass.simpleName, data.toString())
        data?.let {
            val expectedLocation: Location? =
                (options[KEY_GEOTAG_EXPECTED_LOCATION] as Map<String, Any>?)?.let { params ->
                    val lat = params[KEY_LATITUDE] as Double
                    val lng = params[KEY_LONGITUDE] as Double
                    Location("").apply {
                        latitude = lat
                        longitude = lng
                    }
                }
            when (val geotagResult = sdk.addGeotag(data, expectedLocation)) {
                is GeotagResult.SuccessWithDeviation -> {
                    result.success(serializeSuccess(geotagResult.getDeviceLocation()))
                }
                is GeotagResult.Success -> {
                    result.success(serializeSuccess(geotagResult.getDeviceLocation()))
                }
                is GeotagResult.Error -> {
                    result.success(serializeFailure(getLocationError(geotagResult.getReason())))
                }
            }
        } ?: result.error(ERROR_CODE_METHOD_CALL, "Geotag data is null", null)
    }

    private fun setAvailability(
        result: MethodChannel.Result,
        sdk: HyperTrack,
        isAvailable: Boolean
    ) {
        if (isAvailable == true) {
            sdk.setAvailability(Availability.AVAILABLE)
        } else if (isAvailable == false) {
            sdk.setAvailability(Availability.UNAVAILABLE)
            result.success(null)
        }
    }

    private fun getLocationError(error: TrackingError): LocationError {
        return Errors(getTrackingErrors(error))
    }

    private fun getLocationError(error: OutageReason): LocationError {
        val blockersErrors = getHyperTrackErrorsFromBlockers()
        return when (error) {
            OutageReason.NO_GPS_SIGNAL -> {
                Errors(setOf(HyperTrackError.gpsSignalLost) + blockersErrors)
            }
            OutageReason.MISSING_LOCATION_PERMISSION -> {
                Errors(setOf(HyperTrackError.locationPermissionsDenied) + blockersErrors)
            }
            OutageReason.LOCATION_SERVICE_DISABLED -> {
                Errors(setOf(HyperTrackError.locationServicesDisabled) + blockersErrors)
            }
            OutageReason.MISSING_ACTIVITY_PERMISSION -> {
                Errors(setOf(HyperTrackError.motionActivityPermissionsDenied) + blockersErrors)
            }
            OutageReason.NOT_TRACKING -> {
                NotRunning
            }
            OutageReason.START_HAS_NOT_FINISHED -> {
                Starting
            }
            OutageReason.RESTART_REQUIRED -> {
                throw IllegalStateException("RESTART_REQUIRED must not be returned")
            }
        }
    }

    private fun getLocationError(error: Reason): LocationError {
        val blockersErrors = getHyperTrackErrorsFromBlockers()
        return when (error) {
            Reason.NO_GPS_SIGNAL -> {
                Errors(setOf(HyperTrackError.gpsSignalLost) + blockersErrors)
            }
            Reason.MISSING_LOCATION_PERMISSION -> {
                Errors(setOf(HyperTrackError.locationPermissionsDenied) + blockersErrors)
            }
            Reason.LOCATION_SERVICE_DISABLED -> {
                Errors(setOf(HyperTrackError.locationServicesDisabled) + blockersErrors)
            }
            Reason.MISSING_ACTIVITY_PERMISSION -> {
                Errors(setOf(HyperTrackError.motionActivityPermissionsDenied) + blockersErrors)
            }
            Reason.NOT_TRACKING -> {
                NotRunning
            }
            Reason.START_HAS_NOT_FINISHED -> {
                Starting
            }
        }
    }

    private fun getTrackingErrors(error: TrackingError): Set<HyperTrackError> {
        return when (error.code) {
            TrackingError.INVALID_PUBLISHABLE_KEY_ERROR -> {
                HyperTrackError.invalidPublishableKey
            }
            TrackingError.PERMISSION_DENIED_ERROR -> {
                HyperTrackError.permissionsDenied
            }
            TrackingError.AUTHORIZATION_ERROR -> {
                HyperTrackError.blockedFromRunning
            }
            TrackingError.GPS_PROVIDER_DISABLED_ERROR -> {
                HyperTrackError.locationServicesDisabled
            }
            TrackingError.UNKNOWN_NETWORK_ERROR -> {
                HyperTrackError.blockedFromRunning
            }
            else -> {
                throw RuntimeException("Unknown tracking error")
            }
        }.let {
            setOf(it) + getHyperTrackErrorsFromBlockers()
        }
    }

    private fun getHyperTrackErrorsFromBlockers(): Set<HyperTrackError> {
        return HyperTrack.getBlockers().map {
            when (it) {
                Blocker.LOCATION_PERMISSION_DENIED -> {
                    HyperTrackError.locationPermissionsDenied
                }
                Blocker.LOCATION_SERVICE_DISABLED -> {
                    HyperTrackError.locationServicesDisabled
                }
                Blocker.ACTIVITY_PERMISSION_DENIED -> {
                    HyperTrackError.motionActivityPermissionsDenied
                }
                Blocker.BACKGROUND_LOCATION_DENIED -> {
                    HyperTrackError.locationPermissionsInsufficientForBackground
                }
            }
        }.toSet()
    }

    private fun serializeSuccess(location: Location): Map<String, Any> {
        return mapOf(
            KEY_TYPE to TYPE_RESULT_SUCCESS,
            KEY_VALUE to serializeLocation(location)
        )
    }

    private fun serializeFailure(locationError: LocationError): Map<String, Any> {
        return mapOf(
            KEY_TYPE to TYPE_RESULT_FAILURE,
            KEY_VALUE to serializeLocationError(locationError)
        )
    }

    private fun serializeLocationResponse(result: Result<Location, OutageReason>): Map<String, Any> {
        return if (result.isSuccess()) {
            serializeSuccess(result.getValue())
        } else {
            serializeFailure(getLocationError(result.getError()))
        }
    }

    private fun serializeIsTracking(isTracking: Boolean): Map<String, Boolean> {
        return mapOf(KEY_IS_TRACKING to isTracking)
    }

    private fun serializeAvailability(isAvailable: Boolean): Map<String, Boolean> {
        return mapOf(KEY_AVAILABILITY to isAvailable)
    }

    private fun serializeLocation(location: Location): Map<String, Double> {
        return mapOf(
            KEY_LATITUDE to location.latitude,
            KEY_LONGITUDE to location.longitude
        )
    }

    private fun serializeLocationError(locationError: LocationError): Map<String, Any> {
        return when(locationError) {
            NotRunning -> {
                mapOf(KEY_TYPE to TYPE_LOCATION_ERROR_NOT_RUNNING)
            }
            Starting -> {
                mapOf(KEY_TYPE to TYPE_LOCATION_ERROR_STARTING)
            }
            is Errors -> {
                mapOf(
                    KEY_TYPE to TYPE_LOCATION_ERROR_ERRORS,
                    KEY_VALUE to locationError.errors.map { serializeHypertrackError(it) }
                )
            }
        }
    }

    private fun serializeHypertrackError(error: HyperTrackError): Map<String, String> {
        return mapOf(
            KEY_TYPE to error.name,
        )
    }

    companion object {
        private const val METHOD_CHANNEL_NAME = "sdk.hypertrack.com/methods"
        private const val TRACKING_STATE_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/trackingState"
        private const val ERROR_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/trackingError"
        private const val AVAILABILTY_EVENT_CHANNEL_NAME = "sdk.hypertrack.com/availability"

        private const val KEY_TYPE = "type"
        private const val KEY_VALUE = "value"

        private const val TYPE_RESULT_SUCCESS = "success"
        private const val TYPE_RESULT_FAILURE = "failure"

        private const val TYPE_LOCATION_ERROR_NOT_RUNNING = "notRunning"
        private const val TYPE_LOCATION_ERROR_STARTING = "starting"
        private const val TYPE_LOCATION_ERROR_ERRORS = "errors"
        private const val TYPE_HYPERTRACK_ERROR = "hypertrackError"

        private const val KEY_AVAILABILITY = "available"
        private const val KEY_IS_TRACKING = "isTracking"
        private const val KEY_LATITUDE = "latitude"
        private const val KEY_LONGITUDE = "longitude"
        private const val KEY_GEOTAG_DATA = "data"
        private const val KEY_GEOTAG_EXPECTED_LOCATION = "expectedLocation"

        private const val ERROR_CODE_INIT = "init_error"
        private const val ERROR_CODE_SDK_NOT_INITIALIZED = "sdk_not_initialized_error"

        private const val ERROR_CODE_METHOD_CALL = "method_call_error"

        private const val ERROR_CODE_STREAM_INIT = "stream_init_error"
        private const val ERROR_MESSAGE_STREAM_INIT = "Unable to create stream before SDK init"
    }
}

