package com.hypertrack.sdk.flutter


import android.content.Context
import android.location.Location
import android.util.Log
import androidx.annotation.NonNull
import com.hypertrack.sdk.GeotagResult
import com.hypertrack.sdk.HyperTrack
import com.hypertrack.sdk.TrackingError
import com.hypertrack.sdk.TrackingStateObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*

/** HyperTrackPlugin */
public class HyperTrackPlugin(): FlutterPlugin, MethodCallHandler, StreamHandler {

  private var applicationContext : Context? = null
  private var methodChannel : MethodChannel? = null
  private var eventChannel : EventChannel? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    Log.i(TAG, "onAttachedToEngine")
    val context = flutterPluginBinding.applicationContext
    val binaryMessenger = flutterPluginBinding.binaryMessenger
    onAttachedToEngine(context, binaryMessenger)
  }

  private fun onAttachedToEngine(context: Context, messenger: BinaryMessenger) {
    applicationContext = context
    methodChannel = MethodChannel(messenger, HYPERTRACK_SDK_METHOD_CHANNEL)
    methodChannel?.setMethodCallHandler(this)
    eventChannel = EventChannel(messenger, HYPERTRACK_SDK_STATE_CHANNEL)
    eventChannel?.setStreamHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = null
    methodChannel?.setMethodCallHandler(null)
    methodChannel = null
    eventChannel?.setStreamHandler(null)
    eventChannel = null
  }

  companion object {
    private const val TAG = "SdkPlugin"
    private const val HYPERTRACK_SDK_METHOD_CHANNEL = "sdk.hypertrack.com/handle"
    private const val HYPERTRACK_SDK_STATE_CHANNEL = "sdk.hypertrack.com/trackingState"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      Log.i(TAG, "registerWith")

      registrar.activity()?.applicationContext?.let { context -> 
        val messenger = registrar.messenger()
        HyperTrackPlugin().onAttachedToEngine(context, messenger)
      } ?: run {
        Log.i(TAG, "failedRegister")
        result.error("FAILED_REGISTER", "Internal Error: registerWith(registrar:) - registrar.activity() is null", null)
      }
    }
  }  
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "initialize") {
      initialize(call.arguments(), result)
      return
    } else if (call.method == "enableDebugLogging") {
      enableDebugLogging()
      return
    }

    val sdk = sdkInstance
    if (sdk == null) {
      result.error("NOT_INITIALIZED", "Internal Error: onMethodCall(call:,result:) - sdkInstance is null", null)
      return
    }

    when (call.method) {
      "getDeviceId" -> result.success(sdk.deviceID)
      "isRunning" -> result.success(sdk.isRunning)
      "start" -> start(result, sdk)
      "stop" -> stop(result, sdk)
      "addGeotag" -> addGeotag(call.arguments()!!, result, sdk)
      "allowMockLocations" -> allowMockLocations(result, sdk)
      "setDeviceName" -> setDeviceName(call.arguments()!!, result, sdk)
      "setDeviceMetadata" -> setDeviceMetadata(call.arguments()!!, result, sdk)
      "syncDeviceSettings" -> syncDeviceSettings(result, sdk)
      else -> result.notImplemented()

    }
  }

  private var sdkInstance : HyperTrack? = null
  private var stateListener : TrackingStateObserver.OnTrackingStateChangeListener? = null

  private fun initialize(publishableKey : String?, result: Result) {
    Log.d(TAG, "getInstance for key $publishableKey")
    if (publishableKey == null) return

    try {
      sdkInstance = HyperTrack.getInstance(publishableKey)
      result.success(null)
      return
    } catch (e: Exception) {
      result.error("INIT_ERROR", e.message, e)
    }
  }

  private fun enableDebugLogging() {
    Log.d(TAG, "enableDebugLogging called")

    HyperTrack.enableDebugLogging()
  }

  private fun start(result: Result, sdk : HyperTrack) {
    Log.d(TAG, "start")

    val listener = object : TrackingStateObserver.OnTrackingStateChangeListener {
      override fun onTrackingStart() {
        Log.d(TAG, "onTrackingStart")
        result.success(null)
        sdk.removeTrackingListener(this)
      }

      override fun onError(p0: TrackingError?) {
        Log.d(TAG, "onError " + p0?.message)
        result.error("Start failed", p0?.message?:"", null)
        sdk.removeTrackingListener(this)
      }

      override fun onTrackingStop() { /* NOOP */ }
    }

    sdk.addTrackingListener(listener).start()

  }

  private fun stop(result: Result, sdk : HyperTrack) {
    Log.d(TAG, "stop")
    sdk.stop()
    result.success(null)
  }

  private fun addGeotag(options : Map<String, Any>, result: Result, sdk : HyperTrack) {
    val data = options["data"] as Map<String, java.io.Serializable>?
    data?.let {
      val expectedLocation: Location? = (options["expectedLocation"] as Map<String, Any>?)?.let { params ->
        val lat = params["latitude"] as Double
        val lng = params["longitude"] as Double
        Location("any").apply{
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

  private fun allowMockLocations(result : Result, sdk : HyperTrack) {
    Log.d(TAG, "allowMockLocations called")

    sdk.allowMockLocations()
    result.success(null)
  }

  private fun setDeviceName(name : String, result : Result, sdk : HyperTrack) {
    Log.d(TAG, "setDeviceName called with name $name")

    sdk.setDeviceName(name)
    result.success(null)
  }

  private fun setDeviceMetadata(data : Map<String, Any>, result: Result, sdk : HyperTrack) {
    Log.d(TAG, "setDeviceMetadata called with data $data")

    sdk.setDeviceMetadata(data)
    result.success(null)
  }

  private fun syncDeviceSettings(result : Result, sdk : HyperTrack) {
    Log.d(TAG, "syncDeviceSettings called")

    sdk.syncDeviceSettings()
    result.success(null)
  }

  override fun onListen(arguments: Any?, events: EventSink?) {
    val sdk = sdkInstance
    if (sdk == null) {
      events?.error("INVALID_STATE", "Cannot create stream before sdk init", null)
      return
    }

    stateListener = object : TrackingStateObserver.OnTrackingStateChangeListener {
      override fun onTrackingStart() {
        events?.success("start")
      }

      override fun onError(p0: TrackingError?) {
        when (p0?.code) {
          TrackingError.INVALID_PUBLISHABLE_KEY_ERROR -> events?.success("publishable_key_error")
          TrackingError.PERMISSION_DENIED_ERROR -> events?.success("permissions_denied")
          TrackingError.AUTHORIZATION_ERROR -> events?.success("auth_error")
          TrackingError.GPS_PROVIDER_DISABLED_ERROR -> events?.success("gps_disabled")
          TrackingError.UNKNOWN_NETWORK_ERROR -> events?.success("network_error")
          else -> events?.success(p0?.message?:"unknown error")
        }
      }

      override fun onTrackingStop() {
        events?.success("stop")
      }
    }

    sdk.addTrackingListener(stateListener)

  }

  override fun onCancel(arguments: Any?) {
    sdkInstance?.removeTrackingListener(stateListener)
    stateListener = null
  }
}

