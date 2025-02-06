package com.hypertrack.sdk.flutter.common

import com.hypertrack.sdk.android.HyperTrack
import com.hypertrack.sdk.android.Json
import com.hypertrack.sdk.android.Result
import com.hypertrack.sdk.flutter.common.Serialization.deserializeAllowMockLocation
import com.hypertrack.sdk.flutter.common.Serialization.deserializeDynamicPublishableKey
import com.hypertrack.sdk.flutter.common.Serialization.deserializeGeotagData
import com.hypertrack.sdk.flutter.common.Serialization.deserializeIsAvailable
import com.hypertrack.sdk.flutter.common.Serialization.deserializeIsTracking
import com.hypertrack.sdk.flutter.common.Serialization.deserializeMetadata
import com.hypertrack.sdk.flutter.common.Serialization.deserializeName
import com.hypertrack.sdk.flutter.common.Serialization.deserializeOrderHandle
import com.hypertrack.sdk.flutter.common.Serialization.deserializeWorkerHandle
import com.hypertrack.sdk.flutter.common.Serialization.serializeAllowMockLocation
import com.hypertrack.sdk.flutter.common.Serialization.serializeDeviceId
import com.hypertrack.sdk.flutter.common.Serialization.serializeDynamicPublishableKey
import com.hypertrack.sdk.flutter.common.Serialization.serializeErrors
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsAvailable
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsInsideGeofence
import com.hypertrack.sdk.flutter.common.Serialization.serializeIsTracking
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocationErrorFailure
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocationResult
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocationSuccess
import com.hypertrack.sdk.flutter.common.Serialization.serializeLocationWithDeviationSuccess
import com.hypertrack.sdk.flutter.common.Serialization.serializeMetadata
import com.hypertrack.sdk.flutter.common.Serialization.serializeName
import com.hypertrack.sdk.flutter.common.Serialization.serializeOrders
import com.hypertrack.sdk.flutter.common.Serialization.serializeWorkerHandle

typealias Serialized = Map<String, Any?>

/**
 * This class stores SDK instance, calls HyperTrack SDK methods and serializes responses.
 * It receives serialized params.
 */
internal object HyperTrackSdkWrapper {
    fun addGeotag(args: Serialized): WrapperResult<Serialized> =
        deserializeGeotagData(args)
            .flatMapSuccess { geotag ->
                // TODO: return proper error if JSON is wrong
                val geotagMetadata = Json.fromMap(geotag.data)!!
                val expectedLocation =
                    geotag
                        .expectedLocation
                        ?.let {
                            HyperTrack.Location(
                                latitude = it.latitude,
                                longitude = it.longitude,
                            )
                        }
                val orderHandle = geotag.orderHandle
                val orderStatus = geotag.orderStatus
                if (expectedLocation != null) {
                    if (orderHandle != null || orderStatus != null) {
                        if (orderHandle == null || orderStatus == null) {
                            throw Error("orderHandle and orderStatus must be provided")
                        }
                        HyperTrack.addGeotag(
                            orderHandle = orderHandle,
                            orderStatus = orderStatus,
                            expectedLocation = expectedLocation,
                            metadata = geotagMetadata,
                        )
                    } else {
                        HyperTrack.addGeotag(geotagMetadata, expectedLocation)
                    }.let {
                        when (it) {
                            is Result.Failure -> {
                                serializeLocationErrorFailure(it.failure)
                            }

                            is Result.Success -> {
                                serializeLocationWithDeviationSuccess(it.success)
                            }
                        }
                    }
                } else {
                    if (orderHandle != null || orderStatus != null) {
                        if (orderHandle == null || orderStatus == null) {
                            throw Error("orderHandle and orderStatus must be provided")
                        }
                        HyperTrack.addGeotag(
                            orderHandle = orderHandle,
                            orderStatus = orderStatus,
                            metadata = geotagMetadata,
                        )
                    } else {
                        HyperTrack.addGeotag(geotagMetadata)
                    }.let { serializeLocationResult(it) }
                }.let {
                    Success(it)
                }
            }

    fun getAllowMockLocation(): WrapperResult<Serialized> = Success(serializeAllowMockLocation(HyperTrack.allowMockLocation))

    fun getDeviceId(): WrapperResult<Serialized> = Success(serializeDeviceId(HyperTrack.deviceID))

    fun getDynamicPublishableKey(): WrapperResult<Serialized> = Success(serializeDynamicPublishableKey(HyperTrack.dynamicPublishableKey))

    fun getErrors(): WrapperResult<List<Serialized>> = Success(serializeErrors(HyperTrack.errors))

    fun getIsAvailable(): WrapperResult<Serialized> =
        Success(
            serializeIsAvailable(HyperTrack.isAvailable),
        )

    fun getIsTracking(): WrapperResult<Serialized> =
        Success(
            serializeIsTracking(HyperTrack.isTracking),
        )

    fun getLocation(): WrapperResult<Serialized> =
        HyperTrack
            .location
            .let {
                when (it) {
                    is Result.Failure -> serializeLocationErrorFailure(it.failure)
                    is Result.Success -> serializeLocationSuccess(it.success)
                }
            }.let { Success(it) }

    fun getMetadata(): WrapperResult<Serialized> =
        Success(
            serializeMetadata(HyperTrack.metadata.toMap()),
        )

    fun getName(): WrapperResult<Serialized> =
        Success(
            serializeName(HyperTrack.name),
        )

    fun getOrders(): WrapperResult<Serialized> =
        Success(
            serializeOrders(HyperTrack.orders.values),
        )

    fun getOrderIsInsideGeofence(args: Serialized): WrapperResult<Serialized> =
        deserializeOrderHandle(args)
            .mapSuccess { orderHandle ->
                HyperTrack
                    .orders
                    .values
                    .firstOrNull { it.orderHandle == orderHandle }
                    .let { order ->
                        order?.isInsideGeofence ?: Result.Success(false)
                    }.let {
                        serializeIsInsideGeofence(it)
                    }
            }

    fun getWorkerHandle(): WrapperResult<Serialized> =
        Success(
            serializeWorkerHandle(HyperTrack.workerHandle),
        )

    fun setAllowMockLocation(args: Serialized): WrapperResult<Unit> =
        deserializeAllowMockLocation(args)
            .mapSuccess { allowMockLocation ->
                HyperTrack.allowMockLocation = allowMockLocation
            }

    fun setDynamicPublishableKey(args: Serialized): WrapperResult<Unit> =
        deserializeDynamicPublishableKey(args)
            .mapSuccess { publishableKey ->
                HyperTrack.dynamicPublishableKey = publishableKey
            }

    fun setIsAvailable(args: Serialized): WrapperResult<Unit> =
        deserializeIsAvailable(args)
            .mapSuccess { isAvailable ->
                HyperTrack.isAvailable = isAvailable
            }

    fun setIsTracking(args: Serialized): WrapperResult<Unit> =
        deserializeIsTracking(args)
            .mapSuccess { isTracking ->
                HyperTrack.isTracking = isTracking
            }

    fun setMetadata(args: Serialized): WrapperResult<Unit> =
        deserializeMetadata(args)
            .flatMapSuccess { metadata ->
                WrapperResult.tryAsResult {
                    // TODO: return proper error if JSON is wrong
                    HyperTrack.metadata = Json.fromMap(metadata)!!
                }
            }

    fun setName(args: Serialized): WrapperResult<Unit> =
        deserializeName(args)
            .mapSuccess { name ->
                HyperTrack.name = name
            }

    fun setWorkerHandle(args: Serialized): WrapperResult<Unit> =
        deserializeWorkerHandle(args)
            .mapSuccess { workerHandle ->
                HyperTrack.workerHandle = workerHandle
            }
}
