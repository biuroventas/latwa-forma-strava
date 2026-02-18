import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Wymuś wyświetlenie okna na pierwszym planie
    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    super.awakeFromNib()
  }
}
