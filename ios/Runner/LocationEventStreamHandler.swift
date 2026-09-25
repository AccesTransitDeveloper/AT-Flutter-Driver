import Flutter

class LocationEventStreamHandler: NSObject, FlutterStreamHandler {

    static let shared = LocationEventStreamHandler()

    private var eventSink: FlutterEventSink?

    func sendLocation(_ locationData: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(locationData)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
