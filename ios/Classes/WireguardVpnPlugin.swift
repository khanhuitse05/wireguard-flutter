import Flutter
import UIKit
import NetworkExtension
import NotificationCenter


public class WireguardVpnPlugin: NSObject, FlutterPlugin {

    private static var METHOD_CHANNEL_WIREGUARD = "pingak9/wireguard-flutter"
    private static var EVENT_CHANNEL_WIREGUARD = "pingak9/wireguard-state-flutter"
    private static var flutterEventSink:FlutterEventSink?
    
    public static func sendEvent(message:String){
        WireguardVpnPlugin.sendEvent(message: message, object: nil)
    }
    
    public static func sendEvent(message:String, object: [String : Any]?){
        var dictionary = object ?? [:]
        dictionary["message"] = message
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                WireguardVpnPlugin.flutterEventSink?(jsonString)
                return
            }else{
                print("Failed to convert data to JSON string.")
            }
        } catch {
            print("Error converting dictionary to JSON: \(error)")
        }
        WireguardVpnPlugin.flutterEventSink?(message)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: WireguardVpnPlugin.METHOD_CHANNEL_WIREGUARD, binaryMessenger: registrar.messenger())
        
        let event = FlutterEventChannel(name: WireguardVpnPlugin.EVENT_CHANNEL_WIREGUARD, binaryMessenger: registrar.messenger())
        event.setStreamHandler(StageHandler())
        
        let instance = WireguardVpnPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
        
    class StageHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            WireguardVpnPlugin.flutterEventSink = events
            // Start sending data to Flutter here
            // events("Hello from Swift!")
            return nil
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            WireguardVpnPlugin.flutterEventSink = nil
            // Cleanup when the stream is canceled
            return nil
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case EventNames.methodGetTunnelNames:
              handleGetNames(result: result);
              break;
        case EventNames.methodSetState:
              handleSetState(call, result: result);
              break;
        case EventNames.methodGetStats:
              handleGetStats(call, result: result);
              break;
            default:
              result(FlutterMethodNotImplemented)
              break;
        }
    }

    public func handleGetNames(result: @escaping FlutterResult){
        NotificationCenter.default.post(name: EventNames.notificationGetNames, object: nil)
        result("")
    }
    public func handleSetState(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        let arguments:[String: Any] = stringToDictionary(text: call.arguments as? String)
        let state: Bool = (arguments["state"] as? Int) == 1
        NotificationCenter.default.post(name: EventNames.notificationSetState, object: arguments)
        result(state)
    }
    public func handleGetStats(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        NotificationCenter.default.post(name: EventNames.notificationGetStats, object: call.arguments as? String)
        result("")
    }
    
    // helper
    func stringToDictionary(text: String?) -> [String:Any] {
        if let data = text?.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json ?? [:]
            } catch {
                print("Something went wrong")
            }
        }
        return [:]
    }
}
