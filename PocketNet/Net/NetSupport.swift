import Foundation

public class NetSupport {
    public var net: PocketNet
    
    public init(net: PocketNet) {
        self.net = net
    }
    
    public func netJsonMappableRequest<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((PocketResult<T, NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func netArrayJsonMappableRequest<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((PocketResult<[T], NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processArrayResponse(completion: completion, result: result)
        })
    }
    
    public func netUploadArchives<T: Decodable, S: Decodable>(_ request: NetRequest, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((PocketResult<T, NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.uploadRequest(request, archives: archives,
                                 actualProgress: { progress in
                                    actualProgress(progress)
        },
                                 completion: { [weak self] result in
                                    self?.processResponse(completion: completion, result: result)
        })
    }
    
    public func processResponse<T: Decodable, S: Decodable>(completion: @escaping ((PocketResult<T, NetErrorDecodable<S>>) -> Void), result: PocketResult<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(PocketResult.failure(NetErrorDecodable.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(PocketResult.failure(NetErrorDecodable.mappingError)); return }
            guard let object: T = try? JSONDecoder().decode(T.self, from: data) else { completion(PocketResult.failure(NetErrorDecodable.mappingError)); return }
            completion(PocketResult.success(object))
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(PocketResult.failure(.emptyResponse))
            case .encodingError:
                completion(PocketResult.failure(.encodingError))
            case .mappingError:
                completion(PocketResult.failure(.mappingError))
            case .noConnection:
                completion(PocketResult.failure(.noConnection))
            case .error(let statusErrorCode, let errorMessage, let errorStringObject):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(PocketResult.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)))
            }
        }
    }
    
    public func processArrayResponse<T: Decodable, S: Decodable>(completion: @escaping ((PocketResult<[T], NetErrorDecodable<S>>) -> Void), result: PocketResult<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(PocketResult.failure(NetErrorDecodable.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(PocketResult.failure(NetErrorDecodable.mappingError)); return }
            guard let object: [T] = try? JSONDecoder().decode([T].self, from: data) else { completion(PocketResult.failure(NetErrorDecodable.mappingError)); return }
            completion(PocketResult.success(object))
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(PocketResult.failure(.emptyResponse))
            case .encodingError:
                completion(PocketResult.failure(.encodingError))
            case .mappingError:
                completion(PocketResult.failure(.mappingError))
            case .noConnection:
                completion(PocketResult.failure(.noConnection))
            case .error(let statusErrorCode, let errorMessage, let errorStringObject):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(PocketResult.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)))
            }
        }
    }
    
}
