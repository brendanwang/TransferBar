import SwiftUI
import AppKit

@main
struct TransferBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    var body: some Scene { Settings { EmptyView() } }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let monitor = TransferMonitor()
    private var item: NSStatusItem!
    private let popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.target = self
        item.button?.action = #selector(togglePopover)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView(monitor: monitor))
        monitor.onChange = { [weak self] in self?.updateStatus() }
        updateStatus()
        monitor.start()
        if !monitor.trusted { togglePopover() }
    }

    @objc private func togglePopover() {
        guard let button = item.button else { return }
        if popover.isShown { popover.performClose(nil) }
        else {
            NSApp.activate(ignoringOtherApps: true)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func updateStatus() {
        guard let button = item.button else { return }
        let active = !monitor.transfers.isEmpty
        if active {
            let fraction = monitor.fraction
            let image = NSImage(size: NSSize(width: 34, height: 16), flipped: false) { rect in
                let track = NSRect(x: 1, y: 4, width: 32, height: 8)
                NSColor.labelColor.withAlphaComponent(0.3).setFill()
                NSBezierPath(roundedRect: track, xRadius: 3, yRadius: 3).fill()
                NSColor.labelColor.setFill()
                let fill = NSRect(x: 2, y: 5, width: 30 * CGFloat(fraction ?? 0.25), height: 6)
                NSBezierPath(roundedRect: fill, xRadius: 2, yRadius: 2).fill()
                return true
            }
            image.isTemplate = true
            button.image = image
            button.title = monitor.fraction.map { " \(Int(($0 * 100).rounded(.down)))%" } ?? " …"
            button.font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        } else {
            button.image = NSImage(systemSymbolName: monitor.trusted ? "arrow.left.arrow.right" : "exclamationmark.circle", accessibilityDescription: "TransferBar")
            button.title = ""
        }
        let label = active ? "\(monitor.transfers.count) Finder operation(s), \(button.title.trimmingCharacters(in: .whitespaces))" : "TransferBar — \(monitor.paused ? "Paused" : monitor.trusted ? "Waiting for Finder transfers" : "Accessibility access needed")"
        button.toolTip = label
        button.setAccessibilityLabel(label)
    }
}
