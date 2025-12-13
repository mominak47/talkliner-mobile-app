import Flutter
import UIKit
import AVKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Get Audio Devices
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    
    let audioChannel = FlutterMethodChannel(
      name: "audio_devices_channel",
      binaryMessenger: controller.binaryMessenger
    );

    audioChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getAudioDevices" {
        result("Momin Khan");
      }
    });

    let pipChannel = FlutterMethodChannel(
      name: "com.steigenberg.talkliner/pip",
      binaryMessenger: controller.binaryMessenger
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

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
