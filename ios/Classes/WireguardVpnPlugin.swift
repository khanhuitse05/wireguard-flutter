import Flutter
import UIKit
import NetworkExtension
import NotificationCenter


public class WireguardVpnPlugin: NSObject, FlutterPlugin {

//  private static var utils : VPNUtils! = VPNUtils()
  private static var METHOD_CHANNEL_WIREGUARD = "pingak9/wireguard-flutter"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: WireguardVpnPlugin.METHOD_CHANNEL_WIREGUARD, binaryMessenger: registrar.messenger())
    let instance = WireguardVpnPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("iOS handle, " + call.method)
    switch call.method {
    case "getTunnelNames":
      handleGetNames(result: result);
      break;
    case "setState":
        handleSetState(call, result: result);
      break;
    case "getStats":
      handleGetStats(result: result);
      break;
    default:
      result(FlutterMethodNotImplemented)
      break;
    }
  }

  public func handleGetNames(result: @escaping FlutterResult){
      NotificationCenter.default.post(name: Notification.Name("wireguard_vpn_set_names"), object: nil)
      result("")
  }
  public func handleSetState(_ call: FlutterMethodCall, result: @escaping FlutterResult){
      let state: Bool? = (call.arguments as? [String: Any])?["state"] as? Bool
      NotificationCenter.default.post(name: Notification.Name("wireguard_vpn_set_state"), object: ["state": state])
      result(state)
  }
  public func handleGetStats(result: @escaping FlutterResult){
      NotificationCenter.default.post(name: Notification.Name("wireguard_vpn_set_stats"), object: nil)
      result("")
  }
}
