package com.hypertrack.sdk.flutter

import com.hypertrack.sdk.flutter.common.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel.EventSink

private const val ERROR_CODE_METHOD_CALL = "method_call_error"

fun Unit.toFlutterResult(call: MethodCall, flutterResult: MethodChannel.Result) {
    return flutterResult.success(null)
}

fun <T> Result<T>.toFlutterResult(call: MethodCall, flutterResult: MethodChannel.Result) {
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

fun <T> Result<T>.sendEventIfError(events: EventSink, errorCode: String, errorMessage: String) {
    if(this is Failure) {
        events.error(errorCode, errorMessage, null)
    }
}


