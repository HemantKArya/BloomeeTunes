import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Custom title bar drawn by Flutter (WindowFrame). The window stays
    // titled, so it keeps its shadow, rounded corners and resizing; the
    // native title bar and traffic lights are hidden so they neither show
    // nor take clicks meant for the custom caption. Set here, before the
    // window appears, so the system bar never flashes.
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.styleMask.insert(.fullSizeContentView)
    for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
      self.standardWindowButton(button)?.isHidden = true
    }
    self.standardWindowButton(.closeButton)?.superview?.superview?.isHidden = true

    super.awakeFromNib()
  }
}
