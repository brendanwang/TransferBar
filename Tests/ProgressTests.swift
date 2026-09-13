import Foundation

@main
struct ProgressTests {
    static func main() {
        func transfer(_ value: Double?) -> TransferProgress {
            TransferProgress(id: UUID().uuidString, title: "Batch", detail: "", fraction: value)
        }
        assert(TransferProgress.normalized(value: 0.42, minimum: nil, maximum: nil) == 0.42)
        assert(TransferProgress.normalized(value: 42, minimum: 0, maximum: 100) == 0.42)
        assert(TransferProgress.normalized(value: 15, minimum: 10, maximum: 20) == 0.5)
        assert(TransferProgress.normalized(value: nil, minimum: 0, maximum: 100) == nil)
        assert(TransferProgress.normalized(value: .nan, minimum: 0, maximum: 1) == nil)
        assert(TransferProgress.normalized(value: 1, minimum: 1, maximum: 1) == nil)
        assert(TransferProgress.normalized(value: 42, minimum: nil, maximum: nil) == nil)
        assert(TransferProgress.overall([]) == nil)
        assert(TransferProgress.overall([transfer(0.2), transfer(0.8)]) == 0.5)
        assert(TransferProgress.overall([transfer(0.2), transfer(nil)]) == nil)
        assert(transfer(0.999).percentage == "99%")
        assert(transfer(1).percentage == "100%")
        assert(TransferProgress.overall([transfer(0.6)]) == 0.6)
        print("13 progress checks passed")
    }
}
