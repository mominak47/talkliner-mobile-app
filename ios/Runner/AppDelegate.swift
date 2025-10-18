import Flutter
import UIKit

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

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
