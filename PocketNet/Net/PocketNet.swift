import Foundation

public typealias ResultNetworkResponse = Swift.Result<NetworkResponse, NetError>

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
    func launchRequest(_ request: NetRequest, completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int
    func uploadRequest(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int
    func downloadRequest(_ request: NetRequest, actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int
    func isReachable() -> Bool
    func setupCaching(_ size: Int)
    func removeCaching()
    func cancelTask(identifier: Int)
}
