import Foundation

public enum NetError: Error {
    case error(statusErrorCode: Int, errorMessage: String)
    case noConnection
    case emptyResponse
    case mappingError
    case encodingError
}
