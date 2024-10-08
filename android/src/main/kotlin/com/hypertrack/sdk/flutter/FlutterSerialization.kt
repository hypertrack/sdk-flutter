package com.hypertrack.sdk.flutter

import com.hypertrack.sdk.flutter.common.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private const val ERROR_CODE_METHOD_CALL = "METHOD_CALL"

internal fun Unit.sendAsFlutterResult(
    call: MethodCall,
    flutterResult: MethodChannel.Result,
) = flutterResult.success(null)

internal fun <T> WrapperResult<T>.sendAsFlutterResult(
    call: MethodCall,
    flutterResult: MethodChannel.Result,
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

                is List<*> -> {
                    flutterResult.success(this.success)
                }

                is NotImplemented -> {
                    flutterResult.notImplemented()
                }

                else -> {
                    flutterResult.error(
                        ERROR_CODE_METHOD_CALL,
                        "onMethodCall(${call.method}) - Invalid response ${this.success}",
                        null,
                    )
                }
            }
        }

        is Failure -> {
            if (this.failure is Exception) {
                flutterResult.error(
                    ERROR_CODE_METHOD_CALL,
                    this.failure.toString(),
                    null,
                )
            } else {
                throw this.failure
            }
        }
    }
}

internal fun <T> WrapperResult<T>.crashAppIfError() {
    if (this is Failure) {
        throw Throwable(this.failure.toString(), this.failure)
    }
}
