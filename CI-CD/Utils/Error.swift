import Foundation

enum Error: String, Throwable {
    case timeout, processingFailed, donwloadURLNotFound
    
    var message: String {
        switch self {
        case .timeout: "Timed out waiting for download URL"
        case .processingFailed: "Processing failed"
        case .donwloadURLNotFound: "Download URL not found"
        }
    }
}

public protocol Throwable: LocalizedError {
    var message: String { get }
}
