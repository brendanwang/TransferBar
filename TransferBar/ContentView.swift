import SwiftUI

struct ContentView: View {
    @ObservedObject var monitor: TransferMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3.weight(.semibold)).foregroundStyle(.tint)
                Text("TransferBar").font(.headline)
                Spacer()
                Circle().fill(monitor.trusted && !monitor.paused ? .green : .orange).frame(width: 7, height: 7)
            }
            if !monitor.trusted {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Your transfers, at a glance.").font(.title3.weight(.semibold))
                    Text("Allow Accessibility access to read Finder’s transfer progress. TransferBar never changes your files.")
                        .foregroundStyle(.secondary)
                    Button("Enable Accessibility…", action: monitor.requestAccess).buttonStyle(.borderedProminent)
                    Text("Enable TransferBar in System Settings. This panel updates automatically.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            } else if monitor.transfers.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: monitor.paused ? "pause.circle" : "externaldrive.badge.checkmark")
                        .font(.system(size: 32, weight: .light)).foregroundStyle(.secondary)
                    Text(monitor.paused ? "Monitoring paused" : monitor.unavailable ? "Waiting for Finder" : "Ready for your next transfer")
                        .font(.headline)
                    Text(monitor.paused ? "Resume to show Finder progress in the menu bar." : monitor.unavailable ? "Finder’s progress is temporarily unavailable. Retrying automatically." : "Copy or move files in Finder — to a USB drive, another disk, or a folder on this Mac.")
                        .font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(.vertical, 12)
            } else {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(monitor.transfers.count) active \(monitor.transfers.count == 1 ? "operation" : "operations")").font(.headline)
                    Spacer()
                    Text(monitor.fraction.map { "\(Int(($0 * 100).rounded(.down)))%" } ?? "Preparing…")
                        .font(.title2.monospacedDigit().weight(.semibold))
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(monitor.transfers) { transfer in
                            VStack(alignment: .leading, spacing: 7) {
                                HStack(alignment: .top) {
                                    Text(transfer.title).fontWeight(.medium).lineLimit(2)
                                    Spacer()
                                    Text(transfer.percentage).monospacedDigit().foregroundStyle(.secondary)
                                }
                                if let fraction = transfer.fraction { ProgressView(value: fraction) }
                                else { ProgressView().controlSize(.small) }
                                if !transfer.detail.isEmpty {
                                    Text(transfer.detail).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                                }
                            }
                        }
                    }
                }.frame(maxHeight: 260)
                if monitor.transfers.count > 1 {
                    Text("Menu bar percentage is the average across operations, not a byte-weighted total.")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if monitor.unavailable {
                    Text("Some Finder progress is temporarily unavailable.").font(.caption).foregroundStyle(.orange)
                }
            }
            Divider()
            Text("Tracks progress exposed by Finder, including multi-file batches. Very quick operations may finish between updates.")
                .font(.caption).foregroundStyle(.secondary)
            Toggle("Launch at login", isOn: Binding(get: { monitor.launchAtLogin }, set: monitor.setLogin))
                .toggleStyle(.switch).controlSize(.small)
            if let error = monitor.loginError { Text(error).font(.caption).foregroundStyle(.red) }
            HStack {
                Button(monitor.paused ? "Resume monitoring" : "Pause monitoring") { monitor.paused.toggle() }
                    .disabled(!monitor.trusted)
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }.keyboardShortcut("q")
            }.controlSize(.small)
        }
        .padding(20).frame(width: 370)
    }
}
