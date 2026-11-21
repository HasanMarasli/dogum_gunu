import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Uygulama ön plandayken de yerel bildirimler gösterilsin.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let ikonKanali = FlutterMethodChannel(
      name: "dogum_gunu/ikon",
      binaryMessenger: engineBridge.applicationRegistrar.messenger())
    ikonKanali.setMethodCallHandler { [weak self] call, result in
      guard call.method == "ikonAyarla", let dogumGunu = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.ikonAyarla(dogumGunu ? "DogumGunuIkonu" : nil)
      result(nil)
    }
  }

  // iOS ikonu yalnızca uygulama aktifken değiştirir; değilse aktif olunca dener.
  private func ikonAyarla(_ ikonAdi: String?) {
    let uygulama = UIApplication.shared
    guard uygulama.supportsAlternateIcons, uygulama.alternateIconName != ikonAdi else { return }
    if uygulama.applicationState == .active {
      uygulama.setAlternateIconName(ikonAdi, completionHandler: nil)
      return
    }
    // Tek bekleyen gözlemci tutulur; yeni istek eskisinin yerini alır.
    if let bekleyenIkonGozlemcisi {
      NotificationCenter.default.removeObserver(bekleyenIkonGozlemcisi)
    }
    bekleyenIkonGozlemcisi = NotificationCenter.default.addObserver(
      forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
    ) { [weak self] _ in
      guard let self else { return }
      if let gozlemci = self.bekleyenIkonGozlemcisi {
        NotificationCenter.default.removeObserver(gozlemci)
        self.bekleyenIkonGozlemcisi = nil
      }
      self.ikonAyarla(ikonAdi)
    }
  }

  private var bekleyenIkonGozlemcisi: NSObjectProtocol?
}
