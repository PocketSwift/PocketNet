import Foundation

public class NetSupport {
    public var net: PocketNet
    
    public static var dataFetched: Data?
    
    public init(net: PocketNet) {
        self.net = net
    }
}

//With Data
public extension NetSupport {
    
    func netJsonMappableRequestWithData<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((Swift.Result<T, NetErrorDecodable<S>>, Data?) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponseWithData(completion: completion, result: result)
        })
    }
    
    func processResponseWithData<T: Decodable, S: Decodable>(completion: @escaping ((Swift.Result<T, NetErrorDecodable<S>>, Data?) -> Void), result: Swift.Result<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(Swift.Result.failure(NetErrorDecodable.emptyResponse), nil)
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError), nil); return }
            
            guard let object: T = try? JSONDecoder().decode(T.self, from: data) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError), nil); return }
            completion(Swift.Result.success(object), data)
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(Swift.Result.failure(.emptyResponse), nil)
            case .encodingError:
                completion(Swift.Result.failure(.encodingError), nil)
            case .mappingError:
                completion(Swift.Result.failure(.mappingError), nil)
            case .noConnection:
                completion(Swift.Result.failure(.noConnection), nil)
            case .error(let statusErrorCode, let errorMessage, let errorStringObject, _):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(Swift.Result.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)), nil)
            }
        }
    }
    
    func netArrayJsonMappableRequestWithData<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((Swift.Result<[T], NetErrorDecodable<S>>, Data?) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processArrayResponseWithData(completion: completion, result: result)
        })
    }
    
    func processArrayResponseWithData<T: Decodable, S: Decodable>(completion: @escaping ((Swift.Result<[T], NetErrorDecodable<S>>, Data?) -> Void), result: Swift.Result<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(Swift.Result.failure(NetErrorDecodable.emptyResponse), nil)
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError), nil); return }
            
            guard let object: [T] = try? JSONDecoder().decode([T].self, from: data) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError), nil); return }
            completion(Swift.Result.success(object), data)
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(Swift.Result.failure(.emptyResponse), nil)
            case .encodingError:
                completion(Swift.Result.failure(.encodingError), nil)
            case .mappingError:
                completion(Swift.Result.failure(.mappingError), nil)
            case .noConnection:
                completion(Swift.Result.failure(.noConnection), nil)
            case .error(let statusErrorCode, let errorMessage, let errorStringObject, _):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(Swift.Result.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)), nil)
            }
        }
    }
    
}

//Without Data
public extension NetSupport {
    
    func netJsonMappableRequest<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((Swift.Result<T, NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processResponse(completion: completion, result: result)
        })
    }
    
    func processResponse<T: Decodable, S: Decodable>(completion: @escaping ((Swift.Result<T, NetErrorDecodable<S>>) -> Void), result: Swift.Result<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(Swift.Result.failure(NetErrorDecodable.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError)); return }
            
            guard let object: T = try? JSONDecoder().decode(T.self, from: data) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError)); return }
            completion(Swift.Result.success(object))
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(Swift.Result.failure(.emptyResponse))
            case .encodingError:
                completion(Swift.Result.failure(.encodingError))
            case .mappingError:
                completion(Swift.Result.failure(.mappingError))
            case .noConnection:
                completion(Swift.Result.failure(.noConnection))
            case .error(let statusErrorCode, let errorMessage, let errorStringObject, _):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(Swift.Result.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)))
            }
        }
    }
    
    func netArrayJsonMappableRequest<T: Decodable, S: Decodable>(_ request: NetRequest, completion: @escaping ((Swift.Result<[T], NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.launchRequest(request, completion: { [weak self] result in
            self?.processArrayResponse(completion: completion, result: result)
        })
    }
    
    func processArrayResponse<T: Decodable, S: Decodable>(completion: @escaping ((Swift.Result<[T], NetErrorDecodable<S>>) -> Void), result: Swift.Result<NetworkResponse, NetError>) {
        switch result {
        case .success(let netResponse):
            guard netResponse.message != "" else {
                completion(Swift.Result.failure(NetErrorDecodable.emptyResponse))
                return
            }
            guard let data: Data = netResponse.message.data(using: String.Encoding.utf8) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError)); return }
            
            guard let object: [T] = try? JSONDecoder().decode([T].self, from: data) else { completion(Swift.Result.failure(NetErrorDecodable.mappingError)); return }
            completion(Swift.Result.success(object))
        case .failure(let netError):
            switch netError {
            case .emptyResponse:
                completion(Swift.Result.failure(.emptyResponse))
            case .encodingError:
                completion(Swift.Result.failure(.encodingError))
            case .mappingError:
                completion(Swift.Result.failure(.mappingError))
            case .noConnection:
                completion(Swift.Result.failure(.noConnection))
            case .error(let statusErrorCode, let errorMessage, let errorStringObject, _):
                var errorObject: S?
                if let stringToData = errorStringObject, let data: Data = stringToData.data(using: String.Encoding.utf8), let object: S = try? JSONDecoder().decode(S.self, from: data) {
                    errorObject = object
                }
                completion(Swift.Result.failure(NetErrorDecodable.error(statusErrorCode: statusErrorCode, errorMessage: errorMessage, errorObject: errorObject)))
            }
        }
    }
    
    func netUploadArchives<T: Decodable, S: Decodable>(_ request: NetRequest, archives: [FormData], jsonKey: String, actualProgress:@escaping ((Double) -> Void), completion: @escaping ((Swift.Result<T, NetErrorDecodable<S>>) -> Void)) -> Int {
        return net.uploadRequest(request, archives: archives, jsonKey: jsonKey,
                                 actualProgress: { progress in
                                    actualProgress(progress)
        },
                                 completion: { [weak self] result in
                                    self?.processResponse(completion: completion, result: result)
        })
    }
    
}
