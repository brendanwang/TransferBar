# TransferBar

A native macOS 14+ menu bar utility that mirrors Finder's exposed operation progress. It does not copy, modify, or intercept files.

## Run

Open `TransferBar.xcodeproj`, select the TransferBar scheme and My Mac, then Run. Click the menu bar icon and choose **Enable Accessibility…**. Enable TransferBar under System Settings → Privacy & Security → Accessibility. The app detects permission changes automatically. If a development rebuild invalidates authorization, remove the old entry and add the current build again.

Copy or move files in Finder as usual. Local folders, mounted USB storage, external disks, and mounted network drives use the same Finder progress UI. A multi-file or folder copy appears as Finder's batch operation; simultaneous operation indicators appear as separate rows. The menu bar shows the equal-weight average of all determinate operations. It is not a combined byte percentage, because Finder does not consistently expose byte totals. Unknown progress shows an ellipsis instead of a fabricated number.

The app reads Finder's Accessibility hierarchy on a background task about every 750 ms, with bounded traversal and messaging timeouts. It requires an unsandboxed build for cross-application Accessibility. No network access, privileged helper, disk scanning, or Full Disk Access is used. Launch at login uses Apple's ServiceManagement API; use a stable app location for that option.

## Scope and limitations

- Observes progress indicators Finder exposes in its windows/dialogs. It does not offer a system-wide file-transfer API or monitor Terminal and arbitrary third-party applications.
- Finder's unrelated operation dialogs may also expose progress indicators and appear in the list. TransferBar calls these “operations” rather than guessing their type from localized text.
- Finder may hide or omit Accessibility progress on particular macOS versions or dialog states. If it exposes no indicator, there is nothing to report. Operations that finish between polls may not appear.
- An operation disappearing is not proof of successful completion: it may have finished, failed, or been cancelled. The app does not issue completion notifications or retain an assumed-success history.
- Pause stops monitoring; it does not pause the underlying copy. Use Finder to cancel or manage copies.

## Validation

Signed Debug build passed on the development Mac. Progress normalization and aggregation have 13 executable checks:

```sh
swiftc TransferBar/TransferProgress.swift Tests/ProgressTests.swift -o /tmp/TransferBar-progress-tests
/tmp/TransferBar-progress-tests
xcodebuild -scheme TransferBar -configuration Debug build
```

Live Finder copy/move and physical USB validation remain pending Accessibility authorization. Manually verify one large copy, a nested multi-file batch, two simultaneous copies, cancellation, a disconnected destination, indeterminate preparation, permission revocation, and Finder relaunch. A same-volume move can finish instantly and legitimately show no progress.

Apple API references: [AXUIElement](https://developer.apple.com/documentation/applicationservices/axuielement_h), [Accessibility progress indicators](https://developer.apple.com/documentation/appkit/nsaccessibilityprogressindicator), [Accessibility authorization](https://developer.apple.com/documentation/applicationservices/1459186-axisprocesstrustedwithoptions).
