import Foundation

public class PocketAlamofireAdapter {
    
    public static func adaptRequest(_ request: NetRequest, manager: SessionManager, completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        let afResponse = manager.request(
            request.url,
            method: self.transformMethod(request.method),
            parameters: request.body.params,
            encoding: self.transformParameterEncoding(request.body.parameterEncoding),
            headers: request.headers).validate().responseString(encoding: .utf8) { afResponse in
                guard let responseString = afResponse.result.value, let headers = afResponse.response?.allHeaderFields, let statusCode = afResponse.response?.statusCode else {
                    var bodyString: String?
                    if let data = afResponse.data {
                        bodyString = String(data: data, encoding: String.Encoding.utf8)
                    }
                    processErrorResponse(afResponse.error, statusCode: afResponse.response?.statusCode, responseHeaders: afResponse.response?.allHeaderFields, bodyString: bodyString, completion: completion)
                    return
                }
                processSuccessResponseString(responseString != "" ? responseString : "{}", responseHeaders: headers, status: statusCode, completion: completion)
        }
        return (afResponse.task != nil) ? afResponse.task!.taskIdentifier : -1
    }
    
    public static func adaptUploadRequest(_ request: NetRequest, manager: SessionManager, archives: [FormData], jsonKey: String, actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        var uploadRequest: Request!
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
            let dataParameters = try! JSONSerialization.data(withJSONObject: request.body.params, options: JSONSerialization.WritingOptions(rawValue: 0))
            multipartFormData.append(dataParameters, withName: jsonKey, mimeType: "application/json")
        }, with: urlRequest, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                uploadRequest = upload
                group.leave()
                upload.uploadProgress(closure: { progress in
                    actualProgress(progress.fractionCompleted)
                })
                upload.validate().responseString(encoding: .utf8) { afResponse in
                    guard let responseString = afResponse.result.value, let headers = afResponse.response?.allHeaderFields, let statusCode = afResponse.response?.statusCode else {
                        var bodyString: String?
                        if let data = afResponse.data {
                            bodyString = String(data: data, encoding: String.Encoding.utf8)
                        }
                        processErrorResponse(afResponse.error, statusCode: afResponse.response?.statusCode, responseHeaders: afResponse.response?.allHeaderFields, bodyString: bodyString, completion: completion)
                        return
                    }
                    processSuccessResponseString(responseString, responseHeaders: headers, status: statusCode, completion: completion)
                }
            case .failure:
                group.leave()
                completion(Swift.Result.failure(NetError.encodingError))
            }
        })
        group.wait()
        return (uploadRequest.task != nil) ? uploadRequest.task!.taskIdentifier : -1
    }
    
    public static func adaptDownloadRequest(_ request: NetRequest, manager: SessionManager, actualProgress:@escaping ((Double) -> Void), completion: @escaping ((ResultNetworkResponse) -> Void)) -> Int {
        var urlRequest: URLRequest!
        do {
            guard let url = URL(string: request.url) else { return -1 }
            urlRequest = try URLRequest(url: url, method: self.transformMethod(request.method), headers: request.headers)
        } catch {
            return -1
        }
        
        let downloadRequest = manager.download(urlRequest)
            .downloadProgress { progress in
                actualProgress(progress.fractionCompleted)
            }
            .validate().responseString(encoding: .utf8) { afResponse in
                guard let responseString = afResponse.result.value, let headers = afResponse.response?.allHeaderFields, let statusCode = afResponse.response?.statusCode else {
                    var bodyString: String?
                    if let data = afResponse.resumeData{
                        bodyString = String(data: data, encoding: String.Encoding.utf8)
                    }
                    processErrorResponse(afResponse.error, statusCode: afResponse.response?.statusCode, responseHeaders: afResponse.response?.allHeaderFields, bodyString: bodyString, completion: completion)
                    return
                }
                processSuccessResponseString(responseString, responseHeaders: headers, status: statusCode, completion: completion)
        }
        return (downloadRequest.task != nil) ? downloadRequest.task!.taskIdentifier : -1
    }
    
    internal static func processSuccessResponseString(_ responseString: String, responseHeaders: [AnyHashable: Any], status: Int, completion: @escaping ((ResultNetworkResponse) -> Void)) {
        completion(Swift.Result.success(NetworkResponse(statusCode: status, message: responseString, headers: adaptHeaders(responseHeaders))))
    }
    
    internal static func processErrorResponse(_ error: Error?, statusCode: Int?, responseHeaders: [AnyHashable : Any]?, bodyString: String?, completion: @escaping ((ResultNetworkResponse) -> Void)) {
        guard let error = error else {
            completion(Swift.Result.failure(NetError.error(statusErrorCode: -1, errorMessage: "Unknown error", errorStringObject: bodyString, headers: adaptHeaders(responseHeaders))))
            return
        }
        switch error._code {
        case NSURLErrorNotConnectedToInternet:
            completion(Swift.Result.failure(NetError.noConnection))
        default:
            completion(Swift.Result.failure(NetError.error(statusErrorCode: statusCode ?? error._code, errorMessage: error.localizedDescription, errorStringObject: bodyString, headers: adaptHeaders(responseHeaders))))
        }
    }
    
    internal static func adaptHeaders(_ headers: [AnyHashable: Any]?) -> [String: String] {
        var adaptedHeaders = [String: String]()
        for (headerKey, headerValue) in headers ?? [:] {
            let key = headerKey as! String
            let value = headerValue as! String
            adaptedHeaders[key] = value
        }
        return adaptedHeaders
    }
    
    internal static func transformMethod(_ method: Method) -> HTTPMethod {
        switch method {
        case .delete:
            return HTTPMethod.delete
        case .get:
            return HTTPMethod.get
        case .head:
            return HTTPMethod.head
        case .options:
            return HTTPMethod.options
        case .patch:
            return HTTPMethod.patch
        case .post:
            return HTTPMethod.post
        case .put:
            return HTTPMethod.put
        case .trace:
            return HTTPMethod.trace
        case .connect:
            return HTTPMethod.connect
        }
    }
    
    internal static func transformParameterEncoding(_ parameterEncoding: PParameterEncoding) -> ParameterEncoding {
        switch parameterEncoding {
        case .url:
            return URLEncoding.default
        case .json:
            return JSONEncoding.default
        case .form:
            return URLEncoding.default
        }
    }
}
