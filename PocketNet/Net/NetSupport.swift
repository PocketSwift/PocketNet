import Foundation

public class NetSupport {
    public var net: PocketNet

    public init(net: PocketNet) {
        self.net = net
    }

    public func netJsonMappableRequest<T: Convertible>(_ request: NetRequest, completion: @escaping ((PocketResult<T, NetError>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func netUploadArchives<T: Convertible>(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((PocketResult<T, NetError>) -> Void)) -> Int {
        return net.uploadRequest(request, archives: archives,
        actualProgress: { progress in
            actualProgress(progress)
        },
        completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func  processResponse<T: Convertible>(completion: @escaping ((PocketResult<T, NetError>) -> Void), result: PocketResult<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(PocketResult.failure(NetError.emptyResponse))
                return
            }
            guard let object: T =  T.self.instance(netResponse.message) else {
                completion(PocketResult.failure(NetError.mappingError))
                return
            }
            completion(PocketResult.success(object))
        case .failure(let netError):
            completion(PocketResult.failure(netError))
        }
    }
    
}
