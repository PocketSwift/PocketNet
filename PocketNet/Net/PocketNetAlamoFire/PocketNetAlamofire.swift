import Foundation
import Result
import Alamofire
import ResponseDetective

public class PocketNetAlamofire: PocketNet {
    
    public var reachabilityListener: ((NetworkReachabilityStatus?) -> Void)? {
        didSet {
            self.reachabilityManager.stopListening()
            if let reachabilityListener = reachabilityListener {
                self.reachabilityManager.listener = { status in
                    switch status {
                    case .notReachable:
                        reachabilityListener(.notReachable)
                    case .unknown :
                        reachabilityListener(.unknown)
                    case .reachable(.ethernetOrWiFi):
                        reachabilityListener(.reachable(.ethernetOrWiFi))
                    case .reachable(.wwan):
                        reachabilityListener(.reachable(.wwan))
                    }
                }
                self.reachabilityManager.startListening()
            } else {
                self.reachabilityManager.listener = nil
            }
        }
    }
    
    let DF_CACHE_SIZE = 4 * 5 * 1024 * 1024
    let manager: Alamofire.SessionManager
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")!

    public init(requestTimeout: TimeInterval = 20.0) {
        let configuration = URLSessionConfiguration.default
        #if DEBUG
            ResponseDetective.enable(inConfiguration: configuration)
        #endif
        self.manager = Alamofire.SessionManager(configuration: configuration)
        self.manager.session.configuration.timeoutIntervalForRequest = requestTimeout
        self.setupCaching(DF_CACHE_SIZE)
    }

    public func setupCaching(_ size: Int) {
        let URLCache = Foundation.URLCache(memoryCapacity: DF_CACHE_SIZE, diskCapacity: size, diskPath: nil)
        Foundation.URLCache.shared = URLCache
    }
    
    public func removeCaching() {
        self.manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        Foundation.URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }

    public func launchRequest(_ request: NetRequest, completion: @escaping ((AntitypicalResult) -> Void)) -> Int {
        if !request.shouldCache {
            self.manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        } else {
            self.manager.session.configuration.requestCachePolicy = .useProtocolCachePolicy
        }
        return PocketAlamofireAdapter.adaptRequest(request, manager: self.manager, completion: completion)
    }
    
    public func uploadRequest(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((AntitypicalResult) -> Void)) -> Int {
        return PocketAlamofireAdapter.adaptUploadRequest(request, manager: self.manager, archives: archives, actualProgress: actualProgress, completion: completion)
    }

    public func cancelTask(identifier: Int) {
        self.manager.session.getAllTasks { (tasks: [URLSessionTask]) in
            if let task = tasks.filter({ (task: URLSessionTask) -> Bool in
                return task.taskIdentifier == identifier
            }).first, task.state == .running {
                task.cancel()
            }
        }
    }
    
    public func isReachable() -> Bool {
        return self.reachabilityManager.isReachable
    }
    
}
