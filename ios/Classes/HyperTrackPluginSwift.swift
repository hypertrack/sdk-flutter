import Flutter
import HyperTrack

public class HyperTrackPluginSwift: NSObject, FlutterPlugin {
    private let errorsEventChannel: FlutterEventChannel
    private let isAvailableEventChannel: FlutterEventChannel
    private let isTrackingEventChannel: FlutterEventChannel
    private let locationEventChannel: FlutterEventChannel
    private let locateEventChannel: FlutterEventChannel
    private let ordersEventChannel: FlutterEventChannel

    public init(
        errorsEventChannel: FlutterEventChannel,
        isAvailableEventChannel: FlutterEventChannel,
        isTrackingEventChannel: FlutterEventChannel,
        locationEventChannel: FlutterEventChannel,
        locateEventChannel: FlutterEventChannel,
        ordersEventChannel: FlutterEventChannel
    ) {
        self.errorsEventChannel = errorsEventChannel
        self.isAvailableEventChannel = isAvailableEventChannel
        self.isTrackingEventChannel = isTrackingEventChannel
        self.locationEventChannel = locationEventChannel
        self.locateEventChannel = locateEventChannel
        self.ordersEventChannel = ordersEventChannel
        super.init()
    }

    public func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any],
                            fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) -> Bool
    {
        return false
    }

    @objc(registerWithRegistrar:)
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let pluginPrefix = "sdk.hypertrack.com"

        let methodChannel = FlutterMethodChannel(name: "\(pluginPrefix)/methods", binaryMessenger: messenger)

        let errorsEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/errors", binaryMessenger: messenger)
        errorsEventChannel.setStreamHandler(ErrorsStreamHandler())

        let isAvailableEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/isAvailable", binaryMessenger: messenger)
        isAvailableEventChannel.setStreamHandler(IsAvailableStreamHandler())

        let isTrackingEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/isTracking", binaryMessenger: messenger)
        isTrackingEventChannel.setStreamHandler(IsTrackingStreamHandler())

        let locationEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/location", binaryMessenger: messenger)
        locationEventChannel.setStreamHandler(LocationStreamHandler())

        let locateEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/locate", binaryMessenger: messenger)
        locateEventChannel.setStreamHandler(LocateStreamHandler())

        let ordersEventChannel = FlutterEventChannel(name: "\(pluginPrefix)/orders", binaryMessenger: messenger)
        ordersEventChannel.setStreamHandler(OrdersStreamHandler())

        let instance = HyperTrackPluginSwift(
            errorsEventChannel: errorsEventChannel,
            isAvailableEventChannel: isAvailableEventChannel,
            isTrackingEventChannel: isTrackingEventChannel,
            locationEventChannel: locationEventChannel,
            locateEventChannel: locateEventChannel,
            ordersEventChannel: ordersEventChannel
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        registrar.addApplicationDelegate(instance)
    }

    @objc
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let sdkMethod = SDKMethod(rawValue: call.method) else {
            preconditionFailure("Unknown method \(call.method)")
        }
        let args = call.value(forKey: "_arguments") as! [String: Any]?
        let method = call.value(forKey: "_method") as! String

        sendAsFlutterResult(
            result: HyperTrackPluginSwift.handleMethod(sdkMethod, args),
            method: method,
            flutterResult: result
        )
    }

    private static func handleMethod(
        _ sdkMethod: SDKMethod,
        _ args: [String: Any]?
    ) -> Result<SuccessResult, FailureResult> {
        switch sdkMethod {
        case .addGeotag:
            return addGeotag(args!)
        case .getAllowMockLocation:
            return getAllowMockLocation()
        case .getDeviceID:
            return getDeviceID()
        case .getErrors:
            return getErrors()
        case .getIsAvailable:
            return getIsAvailable()
        case .getIsTracking:
            return getIsTracking()
        case .getLocation:
            return getLocation()
        case .getMetadata:
            return getMetadata()
        case .getName:
            return getName()
        case .getOrderIsInsideGeofence:
            return getOrderIsInsideGeofence(args!)
        case .getOrders:
            return getOrders()
        case .getWorkerHandle:
            return getWorkerHandle()
        case .locate:
            // locate is implemented as a Stream
            return .failure(.fatalError("locate() is not implemented as a SDKMethod"))
        case .setAllowMockLocation:
            return setAllowMockLocation(args!)
        case .setIsAvailable:
            return setIsAvailable(args!)
        case .setIsTracking:
            return setIsTracking(args!)
        case .setMetadata:
            return setMetadata(args!)
        case .setName:
            return setName(args!)
        case .setWorkerHandle:
            return setWorkerHandle(args!)
        case .getDynamicPublishableKey:
            preconditionFailure("getDynamicPublishableKey is not implemented")
        case .setDynamicPublishableKey:
            preconditionFailure("setDynamicPublishableKey is not implemented")
        }
    }

    private func sendAsFlutterResult(
        result: Result<SuccessResult, FailureResult>,
        method _: String,
        flutterResult: FlutterResult
    ) {
        switch result {
        case let .success(success):
            switch success {
            case .void:
                flutterResult(true)
            case let .dict(value):
                flutterResult(value)
            case let .array(value):
                flutterResult(value)
            }
        case let .failure(failure):
            switch failure {
            case let .error(message):
                flutterResult(FlutterError(code: "method_call_error",
                                           message: message,
                                           details: nil))
            case let .fatalError(message):
                preconditionFailure(message)
            }
        }
    }
}
