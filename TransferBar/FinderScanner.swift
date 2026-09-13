import AppKit
import ApplicationServices

struct FinderScan: Sendable {
    let transfers: [TransferProgress]
    let unavailable: Bool
}

/// Runs off the main thread. Reads Finder only; never presses controls or changes files.
enum FinderScanner {
    nonisolated static func scan(pid: pid_t) -> FinderScan {
        let app = AXUIElementCreateApplication(pid)
        AXUIElementSetMessagingTimeout(app, 0.2)
        guard let windows = attribute(app, kAXWindowsAttribute) as? [AXUIElement] else {
            return FinderScan(transfers: [], unavailable: true)
        }
        let deadline = Date().addingTimeInterval(1.5)
        var results: [TransferProgress] = []
        var visited = 0
        var incomplete = false
        func walk(_ element: AXUIElement, context: String, depth: Int) {
            guard depth < 18, visited < 1200, Date() < deadline else { incomplete = true; return }
            visited += 1
            let role = attribute(element, kAXRoleAttribute) as? String ?? ""
            if role == kAXProgressIndicatorRole {
                let parent = attribute(element, kAXParentAttribute)
                var nearby: [String] = []
                if let parent, CFGetTypeID(parent) == AXUIElementGetTypeID() {
                    collectText(unsafeDowncast(parent, to: AXUIElement.self), depth: 0, output: &nearby)
                }
                let description = attribute(element, kAXDescriptionAttribute) as? String ?? ""
                let title = nearby.first ?? (context.isEmpty ? "Finder operation" : context)
                let detail = nearby.dropFirst().joined(separator: " · ")
                results.append(TransferProgress(
                    id: "\(pid)-\(CFHash(element))", title: title,
                    detail: detail.isEmpty ? description : detail,
                    fraction: TransferProgress.normalized(
                        value: (attribute(element, kAXValueAttribute) as? NSNumber)?.doubleValue,
                        minimum: (attribute(element, kAXMinValueAttribute) as? NSNumber)?.doubleValue,
                        maximum: (attribute(element, kAXMaxValueAttribute) as? NSNumber)?.doubleValue)))
                return
            }
            // File grids can contain thousands of per-file download indicators. Only inspect
            // window chrome, sheets, and operation dialogs, not Finder's file browser content.
            if [kAXBrowserRole, kAXOutlineRole, kAXTableRole].contains(role) { return }
            let children = attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? []
            for child in children { walk(child, context: context, depth: depth + 1) }
        }
        for window in windows {
            walk(window, context: attribute(window, kAXTitleAttribute) as? String ?? "", depth: 0)
        }
        return FinderScan(transfers: results, unavailable: incomplete)
    }

    nonisolated private static func attribute(_ element: AXUIElement, _ key: String) -> CFTypeRef? {
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, key as CFString, &value) == .success else { return nil }
        return value
    }

    nonisolated private static func collectText(_ element: AXUIElement, depth: Int, output: inout [String]) {
        guard depth < 3, output.count < 8 else { return }
        let role = attribute(element, kAXRoleAttribute) as? String
        if role == kAXStaticTextRole {
            let text = (attribute(element, kAXValueAttribute) as? String)
                ?? (attribute(element, kAXTitleAttribute) as? String) ?? ""
            if !text.isEmpty, !output.contains(text) { output.append(text) }
        }
        for child in (attribute(element, kAXChildrenAttribute) as? [AXUIElement] ?? []).prefix(24) {
            collectText(child, depth: depth + 1, output: &output)
        }
    }
}
