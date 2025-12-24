import Flutter
import UIKit
import AVKit
import PushKit
import flutter_callkit_incoming
import Intents

@main
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        do {
            if let interaction = userActivity.interaction,
               let startCallIntent = interaction.intent as? INStartCallIntent {
                
                let handle = startCallIntent.contacts?.first?.personHandle?.value ?? ""
                
                guard let controller = window?.rootViewController as? FlutterViewController else {
                    return false
                }
                
                let channel = FlutterMethodChannel(name: "com.yourapp/call_intent", binaryMessenger: controller.binaryMessenger)
                channel.invokeMethod("openCallPage", arguments: ["handle": handle])

                print("Call Intent Received: \(handle)")
                return true
            }
        } catch {
            print("Error handling call intent: \(error)")
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Get Audio Devices
    let registrar = self.registrar(forPlugin: "TalklinerMain")!
    
    let audioChannel = FlutterMethodChannel(
      name: "audio_devices_channel",
      binaryMessenger: registrar.messenger()
    );

    audioChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getAudioDevices" {
        result("Momin Khan");
      }
    });

    let pipChannel = FlutterMethodChannel(
      name: "com.steigenberg.talkliner/pip",
      binaryMessenger: registrar.messenger()
    )
    
    pipChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "enableAutoPip" {
        if #available(iOS 15.0, *) {
             // Minimal implementation to acknowledge the call. 
             // Full AVPictureInPictureController requires a player layer or content source which is managed by flutter_webrtc.
             // By acknowledging success, we allow the Flutter side to continue (e.g. background audio).
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
      } else if call.method == "disableAutoPip" {
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    });

    // Register for VoIP Pushes
    let voipRegistry = PKPushRegistry(queue: nil)
    voipRegistry.delegate = self
    voipRegistry.desiredPushTypes = [.voIP]

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Receive the VoIP Token (Send this to your server)
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        let token = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("VoIP Token: \(token)")
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(token);
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    print("didInvalidatePushTokenFor")
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
}

    // Handle the actual incoming VoIP push
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let data = payload.dictionaryPayload
        print("Incoming VoIP Payload: \(data)")

        guard let uuid = data["uuid"] as? String else {
            print("Error: VoIP push missing UUID")
            completion()
            return
        }

        // Map your server payload to CallKit Data
        // Use explicit flutter_callkit_incoming.Data to avoid conflict with Foundation.Data
        let callData = flutter_callkit_incoming.Data(
            id: uuid,
            nameCaller: data["callerName"] as? String ?? "Unknown Caller",
            handle: data["handle"] as? String ?? "Generic",
            type: (data["hasVideo"] as? Bool ?? false) ? 1 : 0 // 0 for Audio, 1 for Video
        )
        callData.extra = (data["livekitData"] as? [String: Any] ?? [:]) as NSDictionary
        
        // This displays the system call UI immediately
        SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(callData, fromPushKit: true)
        
        completion()
    }
    
}
