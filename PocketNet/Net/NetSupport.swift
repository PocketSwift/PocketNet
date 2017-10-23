import Foundation
import Result

public class NetSupport {
    public var net: PocketNet

    public init(net: PocketNet) {
        self.net = net
    }

    public func netJsonMappableRequest<T: Convertible>(_ request: RequestNet, completion: @escaping ((Result<T, NetError>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func netUploadArchives<T: Convertible>(_ request: RequestNet, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((Result<T, NetError>) -> Void)) -> Int {
        return net.uploadRequest(request, archives: archives,
        actualProgress: { progress in
            actualProgress(progress)
        },
        completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func  processResponse<T: Convertible>(completion: @escaping ((Result<T, NetError>) -> Void), result: Result<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(Result.failure(NetError.emptyResponse))
                return
            }
            guard let object: T =  T.self.instance(netResponse.message) else {
                completion(Result.failure(NetError.mappingError))
                return
            }
            completion(Result.success(object))
        case .failure(let netError):
            completion(Result.failure(netError))
        }
    }
    
}
