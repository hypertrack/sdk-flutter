package com.hypertrack.sdk.flutter

import com.hypertrack.sdk.android.*
import com.hypertrack.sdk.flutter.common.*
import com.hypertrack.sdk.flutter.common.Serialization.deserializeGeotagData
import com.hypertrack.sdk.flutter.common.Serialization.serializeErrors
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsAvailable
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsTracking
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocateResult
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocationResult
import com.hypertrack.sdk.flutter.common.Success
import com.hypertrack.sdk.flutter.common.WrapperResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.lang.NullPointerException
import java.util.*

public class HyperTrackPlugin : FlutterPlugin, MethodCallHandler {
    // receives method calls from the plugin API
    private var methodChannel: MethodChannel? = null

    // send events from the SDK to plugin clients
    private var errorsEventChannel: EventChannel? = null
    private var isTrackingEventChannel: EventChannel? = null
    private var isAvailableEventChannel: EventChannel? = null
    private var locateEventChannel: EventChannel? = null
    private var locationEventChannel: EventChannel? = null

    private var errorsCancellable: HyperTrack.Cancellable? = null
    private var isTrackingCancellable: HyperTrack.Cancellable? = null
    private var isAvailableCancellable: HyperTrack.Cancellable? = null
    private var locateCancellable: HyperTrack.Cancellable? = null
    private var locationCancellable: HyperTrack.Cancellable? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val messenger = flutterPluginBinding.binaryMessenger
        methodChannel = MethodChannel(messenger, METHOD_CHANNEL_NAME)
        methodChannel?.setMethodCallHandler(this)
        initEventChannels(messenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null

        errorsCancellable?.cancel()
        isTrackingCancellable?.cancel()
        isAvailableCancellable?.cancel()
        locateCancellable?.cancel()
        locationCancellable?.cancel()

        errorsEventChannel?.setStreamHandler(null)
        isTrackingEventChannel?.setStreamHandler(null)
        isAvailableEventChannel?.setStreamHandler(null)
        locateEventChannel?.setStreamHandler(null)
        locationEventChannel?.setStreamHandler(null)

        errorsEventChannel = null
        isTrackingEventChannel = null
        isAvailableEventChannel = null
        locateEventChannel = null
        locationEventChannel = null
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result,
    ) {
        invokeSdkMethod(call).sendAsFlutterResult(call, result)
    }

    private fun invokeSdkMethod(call: MethodCall): WrapperResult<*> {
        val method =
            SdkMethod
                .values()
                .firstOrNull { it.name == call.method }
                ?: run {
                    return Success(NotImplemented)
                }
        return when (method) {
            SdkMethod.addGeotag -> {
                withArgs<Map<String, Any?>>(call) { args ->
                    deserializeGeotagData(args).flatMapSuccess {
                        HyperTrackSdkWrapper.addGeotag(args)
                    }
                }
            }

            SdkMethod.getDeviceID -> {
                HyperTrackSdkWrapper.getDeviceId()
            }

            SdkMethod.getDynamicPublishableKey -> {
                throw NotImplementedError("getDynamicPublishableKey is not implemented")
            }

            SdkMethod.getErrors -> {
                HyperTrackSdkWrapper.getErrors()
            }

            SdkMethod.getIsAvailable -> {
                HyperTrackSdkWrapper.getIsAvailable()
            }

            SdkMethod.getIsTracking -> {
                HyperTrackSdkWrapper.getIsTracking()
            }

            SdkMethod.getLocation -> {
                HyperTrackSdkWrapper.getLocation()
            }

            SdkMethod.getMetadata -> {
                HyperTrackSdkWrapper.getMetadata()
            }

            SdkMethod.getName -> {
                HyperTrackSdkWrapper.getName()
            }

            SdkMethod.getWorkerHandle -> {
                HyperTrackSdkWrapper.getWorkerHandle()
            }

            SdkMethod.locate -> {
                // locate is implemented as a EventChannel
                Success(NotImplemented)
            }

            SdkMethod.setDynamicPublishableKey -> {
                throw NotImplementedError("setDynamicPublishableKey is not implemented")
            }

            SdkMethod.setIsAvailable -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setIsAvailable(args)
                }
            }

            SdkMethod.setIsTracking -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setIsTracking(args)
                }
            }

            SdkMethod.setMetadata -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setMetadata(args)
                }
            }

            SdkMethod.setName -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setName(args)
                }
            }

            SdkMethod.setWorkerHandle -> {
                withArgs<Unit>(call) { args ->
                    HyperTrackSdkWrapper.setWorkerHandle(args)
                }
            }
        }
    }

    private fun <N> withArgs(
        call: MethodCall,
        block: (Map<String, Any?>) -> WrapperResult<N>,
    ): WrapperResult<N> {
        return call
            .arguments<Map<String, Any?>>()
            ?.let { block.invoke(it) }
            ?: Failure(NullPointerException(call.method))
    }

    private fun initEventChannels(messenger: BinaryMessenger) {
        errorsEventChannel = EventChannel(messenger, ERRORS_EVENT_CHANNEL_NAME)
        errorsEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventSink,
                ) {
                    WrapperResult
                        .tryAsResult {
                            errorsCancellable =
                                HyperTrack.subscribeToErrors { errors ->
                                    events.success(serializeErrors(errors))
                                }
                        }.crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    errorsCancellable?.cancel()
                    errorsCancellable = null
                }
            },
        )

        isTrackingEventChannel = EventChannel(messenger, IS_TRACKING_STATE_EVENT_CHANNEL_NAME)
        isTrackingEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventSink,
                ) {
                    WrapperResult
                        .tryAsResult {
                            isTrackingCancellable =
                                HyperTrack.subscribeToIsTracking { isTracking ->
                                    events.success(serializeIsTracking(isTracking))
                                }
                        }.crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    isTrackingCancellable?.cancel()
                    isTrackingCancellable = null
                }
            },
        )

        isAvailableEventChannel = EventChannel(messenger, IS_AVAILABLE_EVENT_CHANNEL_NAME)
        isAvailableEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventSink,
                ) {
                    WrapperResult
                        .tryAsResult {
                            isAvailableCancellable =
                                HyperTrack.subscribeToIsAvailable { isAvailable ->
                                    events.success(serializeIsAvailable(isAvailable))
                                }
                        }.crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    isAvailableCancellable?.cancel()
                    isAvailableCancellable = null
                }
            },
        )

        locationEventChannel = EventChannel(messenger, LOCATION_EVENT_CHANNEL_NAME)
        locationEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventSink,
                ) {
                    WrapperResult
                        .tryAsResult {
                            locationCancellable =
                                HyperTrack.subscribeToLocation { locationResult ->
                                    events.success(serializeLocationResult(locationResult))
                                }
                        }.crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    locationCancellable?.cancel()
                    locationCancellable = null
                }
            },
        )

        locateEventChannel = EventChannel(messenger, LOCATE_EVENT_CHANNEL_NAME)
        locateEventChannel?.setStreamHandler(
            object : StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventSink,
                ) {
                    WrapperResult
                        .tryAsResult {
                            locateCancellable?.cancel()
                            locateCancellable =
                                HyperTrack.locate { locateResult ->
                                    events.success(serializeLocateResult(locateResult))
                                }
                        }.crashAppIfError()
                }

                override fun onCancel(arguments: Any?) {
                    locateCancellable?.cancel()
                    locateCancellable = null
                }
            },
        )
    }

    companion object {
        private const val PREFIX = "sdk.hypertrack.com"
        private const val METHOD_CHANNEL_NAME = "$PREFIX/methods"
        private const val ERRORS_EVENT_CHANNEL_NAME = "$PREFIX/errors"
        private const val IS_TRACKING_STATE_EVENT_CHANNEL_NAME = "$PREFIX/isTracking"
        private const val IS_AVAILABLE_EVENT_CHANNEL_NAME = "$PREFIX/isAvailable"
        private const val LOCATION_EVENT_CHANNEL_NAME = "$PREFIX/location"
        private const val LOCATE_EVENT_CHANNEL_NAME = "$PREFIX/locate"
    }
}
