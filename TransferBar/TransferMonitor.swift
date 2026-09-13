import AppKit
import ApplicationServices
import Combine
import ServiceManagement

@MainActor
final class TransferMonitor: ObservableObject {
    @Published var transfers: [TransferProgress] = []
    @Published var trusted = AXIsProcessTrusted()
    @Published var unavailable = false
    @Published var paused = false
    @Published var launchAtLogin = SMAppService.mainApp.status == .enabled
    @Published var loginError: String?
    var onChange: (() -> Void)?
    private var loop: Task<Void, Never>?

    var fraction: Double? { TransferProgress.overall(transfers) }

    func start() {
        guard loop == nil else { return }
        loop = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.trusted = AXIsProcessTrusted()
                if self.trusted && !self.paused {
                    if let finder = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder").first {
                        let pid = finder.processIdentifier
                        let result = await Task.detached(priority: .utility) { FinderScanner.scan(pid: pid) }.value
                        self.transfers = result.transfers
                        self.unavailable = result.unavailable
                    } else {
                        self.transfers = []
                        self.unavailable = true
                    }
                } else { self.transfers = []; self.unavailable = false }
                self.onChange?()
                try? await Task.sleep(for: .seconds(0.75))
            }
        }
    }

    func requestAccess() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }

    func setLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            loginError = nil
        } catch { loginError = error.localizedDescription }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }
}
