import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Clicking the Dock icon brings back a window hidden in the menu bar.
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window in sender.windows where window is MainFlutterWindow {
        if window.isMiniaturized {
          window.deminiaturize(self)
        } else {
          window.makeKeyAndOrderFront(self)
        }
      }
      sender.activate(ignoringOtherApps: true)
    }
    return true
  }
}
