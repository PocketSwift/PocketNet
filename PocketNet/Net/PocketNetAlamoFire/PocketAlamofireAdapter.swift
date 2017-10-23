import Foundation
import Alamofire
import Result

public class PocketAlamofireAdapter {

    public static func adaptRequest(_ request: RequestNet, manager: Alamofire.SessionManager, completion: @escaping ((AntitypicalResult) -> Void)) -> Int {
        let afResponse = manager.request(
                request.url,
                method: self.transformMethod(request.method),
                parameters: request.body.params,
                encoding: self.transformParameterEncoding(request.body.parameterEncoding),
                headers: request.headers).validate().responseString { afResponse in
                    self.processResponse(afResponse: afResponse, completion: completion)
        }
        return (afResponse.task != nil) ? afResponse.task!.taskIdentifier : -1
    }
    
    public static func adaptUploadRequest(_ request: RequestNet, manager: Alamofire.SessionManager, archives: [FormData], actualProgress:@escaping ((Double) -> Void), completion: @escaping ((AntitypicalResult) -> Void)) -> Int {
        var uploadRequest: Alamofire.Request!
        var urlRequest: URLRequest!
        do {
            guard let url = URL(string: request.url) else { return -1 }
            urlRequest = try URLRequest(url: url, method: self.transformMethod(request.method), headers: request.headers)
        } catch {
            return -1
        }
        
        let group = DispatchGroup()
        group.enter()
        
        manager.upload(multipartFormData: { (multipartFormData) in
            for archive in archives {
                multipartFormData.append(archive.data, withName: archive.apiName, fileName: archive.fileName, mimeType: archive.mimeType)
            }
            for (key, value) in request.body.params {
                multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: urlRequest, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                uploadRequest = upload
                group.leave()
                upload.uploadProgress(closure: { (progress) in
                    actualProgress(progress.fractionCompleted)
                })
                upload.validate().responseString { afResponse in
                    self.processResponse(afResponse: afResponse, completion: completion)
                }
            case .failure:
                group.leave()
                completion(Result.failure(NetError.encodingError))
            }
        })
        group.wait()
        return (uploadRequest.task != nil) ? uploadRequest.task!.taskIdentifier : -1
    }

    internal static func processResponse(afResponse: DataResponse<String>, completion: @escaping ((AntitypicalResult) -> Void)) {
        switch afResponse.result {
        case .success(let responseString):
            if let responseData = afResponse.response {
                let headers = responseData.allHeaderFields
                
                var adaptedHeaders = [String: String]()
                for (headerKey, headerValue) in headers {
                    let key = headerKey as! String
                    let value = headerValue as! String
                    adaptedHeaders[key] = value
                }
                completion(Result.success(NetworkResponse(statusCode: responseData.statusCode, message: responseString, headers: adaptedHeaders)))
            } else {
                completion(Result.failure(NetError.error(statusErrorCode: 0, errorMessage: "")))
            }
        case .failure(let error):
            switch error._code {
            case NSURLErrorNotConnectedToInternet:
                completion(Result.failure(NetError.noConnection))
            default:
                if let afError = error as? AFError {
                    completion(Result.failure(NetError.error(statusErrorCode: afError.responseCode ?? 0, errorMessage: error.localizedDescription)))
                } else {
                    completion(Result.failure(NetError.error(statusErrorCode: error._code, errorMessage: error.localizedDescription)))
                }
            }
        }
    }

    internal static func transformMethod(_ method: Method) -> Alamofire.HTTPMethod {
        switch method {
        case .delete:
            return Alamofire.HTTPMethod.delete
        case .get:
            return Alamofire.HTTPMethod.get
        case .head:
            return Alamofire.HTTPMethod.head
        case .options:
            return Alamofire.HTTPMethod.options
        case .patch:
            return Alamofire.HTTPMethod.patch
        case .post:
            return Alamofire.HTTPMethod.post
        case .put:
            return Alamofire.HTTPMethod.put
        case .trace:
            return Alamofire.HTTPMethod.trace
        case .connect:
            return Alamofire.HTTPMethod.connect
        }
    }

    internal static func transformParameterEncoding(_ parameterEncoding: ParameterEncoding) -> Alamofire.ParameterEncoding {
        switch parameterEncoding {
        case .url:
            return Alamofire.URLEncoding.default
        case .json:
            return Alamofire.JSONEncoding.default
        case .form:
            return Alamofire.URLEncoding.default
        }
    }
}
