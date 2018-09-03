import Foundation

public enum NetError: Error {
    case error(statusErrorCode: Int, errorMessage: String, errorStringObject: String?)
    case noConnection
    case emptyResponse
    case mappingError
    case encodingError
}

public enum NetErrorDecodable<T>: Error {
    case error(statusErrorCode: Int, errorMessage: String, errorObject: T?)
    case noConnection
    case emptyResponse
    case mappingError
    case encodingError
}

public struct IgnoreError: Decodable {
    
}
