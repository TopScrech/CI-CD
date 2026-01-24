import OSLog

extension Logger {
    func warning(_ message: String) {
        log(level: .default, "Warning: \(message)")
    }
}
