import Foundation

public struct NetworkResponse {
    public let statusCode: Int
    public let message: String
    public let headers: [String: String]

    public init(statusCode: Int) {
        self.init(statusCode: statusCode, message: "", headers: [:])
    }

    public init(statusCode: Int, message: String, headers: [String: String]) {
        self.statusCode = statusCode
        self.message = message
        self.headers = headers
    }
}
