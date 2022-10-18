import Flutter

let errorCodeMethodCall = "method_call_error"
let errorCodeStreamInit = "stream_init_error"

extension Unit {
    func sendAsFlutterResult(result: FlutterResult) {
        result(nil)
    }
}

extension Result {
    func sendAsFlutterResult(_ method: String, _ result: FlutterResult) {
        switch self {
        case .success(let success):
            switch (success) {
            case let succesResult as SuccessResult:
                switch (succesResult) {
                case .void:
                    result(nil)
                case .string(let value):
                    result(value)
                case .dict(let value):
                    result(value)
                }
            default:
                result(FlutterError.init(code: errorCodeMethodCall,
                                         message: "onMethodCall(\(method) - Invalid response \(success)",
                                         details: nil))
            }
            
        case .failure(let failure):
            result(FlutterError.init(code: errorCodeMethodCall,
                                     message: failure as? String,
                                     details: nil))
        }
    }
    
    func sendErrorIfAny(_ eventSink: FlutterEventSink, errorCode: String) {
        switch self {
        case .failure(let failure):
            eventSink(FlutterError.init(code: errorCodeMethodCall,
                                        message: failure as? String,
                                        details: nil))
        default:
            return
        }
    }
}






