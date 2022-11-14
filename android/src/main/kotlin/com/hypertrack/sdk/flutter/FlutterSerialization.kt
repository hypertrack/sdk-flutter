package com.hypertrack.sdk.flutter

import com.hypertrack.sdk.flutter.common.*
import com.hypertrack.sdk.flutter.HyperTrackPlugin.Companion.ERROR_CODE_METHOD_CALL
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel.EventSink
import android.util.Log

internal fun Unit.sendAsFlutterResult(call: MethodCall, flutterResult: MethodChannel.Result) {
    return flutterResult.success(null)
}

internal fun <T> Result<T>.sendAsFlutterResult(
    call: MethodCall,
    flutterResult: MethodChannel.Result
) {
    when (this) {
        is Success -> {
            when (this.success) {
                is Unit -> {
                    flutterResult.success(null)
                }
                is String -> {
                    flutterResult.success(this.success)
                }
                is Map<*, *> -> {
                    flutterResult.success(this.success)
                }
                is NotImplemented -> {
                    flutterResult.notImplemented()
                }
                else -> {
                    flutterResult.error(
                        ERROR_CODE_METHOD_CALL,
                        "onMethodCall(${call.method}) - Invalid response ${this.success}",
                        null
                    )
                }
            }
        }
        is Failure -> {
            if(this.failure is Exception) {
                Log.v(javaClass.simpleName, this.failure.toString())
                flutterResult.error(
                    ERROR_CODE_METHOD_CALL,
                    this.failure.toString(),
                    null
                )
            } else {
                throw this.failure
            }
        }
    }
}

internal fun <T> Result<T>.crashAppIfError() {
    if (this is Failure) {
        throw Throwable(this.failure.toString(), this.failure)
    }
}
