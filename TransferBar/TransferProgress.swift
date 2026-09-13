import Foundation

struct TransferProgress: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let fraction: Double?

    static func normalized(value: Double?, minimum: Double?, maximum: Double?) -> Double? {
        guard let value, value.isFinite else { return nil }
        let lower = minimum ?? 0
        // AX progress values conventionally use 0...1; never guess a percentage scale.
        let upper = maximum ?? 1
        guard lower.isFinite, upper.isFinite, upper > lower,
              value >= lower, value <= upper else { return nil }
        return (value - lower) / (upper - lower)
    }

    static func overall(_ transfers: [TransferProgress]) -> Double? {
        guard !transfers.isEmpty, transfers.allSatisfy({ $0.fraction != nil }) else { return nil }
        return transfers.compactMap(\.fraction).reduce(0, +) / Double(transfers.count)
    }

    var percentage: String { fraction.map { "\(Int(($0 * 100).rounded(.down)))%" } ?? "Preparing…" }
}
