import Foundation
import Result

public typealias AntitypicalResult = Result<NetworkResponse, NetError>

public enum NetworkReachabilityStatus {
    case unknown
    case notReachable
    case reachable(ConnectionType)
}

public enum ConnectionType {
    case ethernetOrWiFi
    case wwan
}

public protocol PocketNet {
    var reachabilityListener: ((NetworkReachabilityStatus?) -> Void)? { get set }
    func launchRequest(_ request: RequestNet, completion: @escaping ((Result<NetworkResponse, NetError>) -> Void)) -> Int
    func uploadRequest(_ request: RequestNet, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((Result<NetworkResponse, NetError>) -> Void)) -> Int
    func isReachable() -> Bool
    func setupCaching(_ size: Int)
    func removeCaching()
    func cancelTask(identifier: Int)
}
