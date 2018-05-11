import Foundation

public class NetSupport {
    public var net: PocketNet
    
    public init(net: PocketNet) {
        self.net = net
    }
    
    public func netJsonMappableRequest<T: Decodable>(_ request: NetRequest, completion: @escaping ((PocketResult<T, NetError>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func netArrayJsonMappableRequest<T: Decodable>(_ request: NetRequest, completion: @escaping ((PocketResult<[T], NetError>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processArrayResponse(completion: completion, result: result)
        })
    }
    
    public func netUploadArchives<T: Decodable>(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((PocketResult<T, NetError>) -> Void)) -> Int {
        return net.uploadRequest(request, archives: archives,
                                 actualProgress: { progress in
                                    actualProgress(progress)
        },
                                 completion: { [weak self] result in
                                    self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func processResponse<T: Decodable>(array: Bool = false, completion: @escaping ((PocketResult<T, NetError>) -> Void), result: PocketResult<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(PocketResult.failure(NetError.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(PocketResult.failure(NetError.mappingError)); return }
            guard let object: T = try? JSONDecoder().decode(T.self, from: data) else { completion(PocketResult.failure(NetError.mappingError)); return }
            completion(PocketResult.success(object))
        case .failure(let netError):
            completion(PocketResult.failure(netError))
        }
    }
    
    public func processArrayResponse<T: Decodable>(completion: @escaping ((PocketResult<[T], NetError>) -> Void), result: PocketResult<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(PocketResult.failure(NetError.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(PocketResult.failure(NetError.mappingError)); return }
            guard let object: [T] = try? JSONDecoder().decode([T].self, from: data) else { completion(PocketResult.failure(NetError.mappingError)); return }
            completion(PocketResult.success(object))
        case .failure(let netError):
            completion(PocketResult.failure(netError))
        }
    }
    
}
