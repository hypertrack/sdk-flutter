package com.hypertrack.sdk.flutter

import com.hypertrack.sdk.flutter.common.*
import com.hypertrack.sdk.flutter.HyperTrackPlugin.Companion.ERROR_CODE_METHOD_CALL
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel.EventSink

internal fun Unit.sendAsFlutterResult(call: MethodCall, flutterResult: MethodChannel.Result) {
    return flutterResult.success(null)
}

internal fun <T> Result<T>.sendAsFlutterResult(call: MethodCall, flutterResult: MethodChannel.Result) {
    when(this) {
        is Success -> {
           when(this.success) {
               is Unit -> {
                   flutterResult.success(null)
               }
               is String -> {
                   flutterResult.success(this.success)
               }
               is Map<*, *> -> {
                   flutterResult.success(this.success)
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
            flutterResult.error(
                ERROR_CODE_METHOD_CALL,
                this.failure.toString(),
                null
            )
        }
    }
}

internal fun <T> Result<T>.sendEventIfError(events: EventSink, errorCode: String) {
    if(this is Failure) {
        events.error(errorCode, this.failure.toString(), null)
    }
}


