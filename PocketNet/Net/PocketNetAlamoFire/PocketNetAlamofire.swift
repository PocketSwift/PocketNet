import Foundation

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
    let manager: SessionManager
    let reachabilityManager = NetworkReachabilityManager(host: "www.apple.com")!
    let customSession: CustomSessionDelegate?

    public init(requestTimeout: TimeInterval = 20.0, pinningSSLCertURL: URL? = nil, domain: String? = nil) {
        var configuration = URLSessionConfiguration.default
        #if DEBUG
            configuration = Reqres.defaultSessionConfiguration()
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        #endif
        if let certURL = pinningSSLCertURL, let dom = domain, let customSession = CustomSessionDelegate(resourceURL: certURL) {
            self.customSession = customSession
            
            let serverTrustPolicies: [String: ServerTrustPolicy] = [
                dom: .pinPublicKeys(
                    publicKeys: ServerTrustPolicy.publicKeys(),
                    validateCertificateChain: true,
                    validateHost: true
                )
            ]
            self.manager = SessionManager(configuration: configuration,
                delegate: customSession,
                serverTrustPolicyManager: CustomServerTrustPolicyManager(
                    policies: serverTrustPolicies
                )
            )
        } else {
            customSession = nil
            self.manager = SessionManager(configuration: configuration)
        }
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

    public func launchRequest(_ request: NetRequest, completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        if !request.shouldCache {
            self.manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        } else {
            self.manager.session.configuration.requestCachePolicy = .useProtocolCachePolicy
        }
        return PocketAlamofireAdapter.adaptRequest(request, manager: self.manager, completion: completion)
    }
    
    public func uploadRequest(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        return PocketAlamofireAdapter.adaptUploadRequest(request, manager: self.manager, archives: archives, actualProgress: actualProgress, completion: completion)
    }
    
    public func downloadRequest(_ request: NetRequest, actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        return PocketAlamofireAdapter.adaptDownloadRequest(request, manager: self.manager, actualProgress: actualProgress, completion: completion)
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
