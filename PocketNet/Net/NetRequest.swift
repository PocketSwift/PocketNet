import Foundation

public typealias Parameters = [String: AnyObject]

public struct NetRequest {
    public let url: String
    public let method: Method
    public let shouldCache: Bool
    public let headers: [String: String]
    public let body: Body

    private init(builder: Builder) {
        self.url = builder.url
        self.method = builder.method
        self.shouldCache = builder.shouldCache
        self.headers = builder.headers
        self.body = Body(parameterEncoding: builder.encoding, params: builder.params)
    }

    public class Builder {
        
        public var url: String = ""
        public var method: Method = .get
        public var headers: [String: String] = [:]
        public var params: Parameters = [:]
        public var encoding: ParameterEncoding = .url
        public var shouldCache: Bool = true
        
        public init() { }
        
        public func url(_ url: String) -> Self {
            self.url = url
            return self
        }
        
        public func method(_ method: Method) -> Self {
            self.method = method
            return self
        }
        
        public func parameter(name: String, value: String) -> Self {
            self.params[name] = value as AnyObject?
            return self
        }
        
        public func body(params: String?) -> Self {
            guard let parameters = params else { return self }
            if let data = parameters.data(using: .utf8) {
                do {
                    guard let dic =  try JSONSerialization.jsonObject(with: data, options: []) as? Parameters
                        else { return self }
                    self.params = dic
                } catch {
                    return self
                }
            }
            return self
        }
        
        public func parameterEncoding(_ parameterEncoding: ParameterEncoding) -> Self {
            self.encoding = parameterEncoding
            return self
        }
        
        public func requestHeader(_ dicRequestHeader: [String: String]) -> Self {
            self.headers = dicRequestHeader
            return self
        }
        
        public func shouldCache(_ shouldCache: Bool) -> Self {
            self.shouldCache = shouldCache
            return self
        }
        
        public func build () -> NetRequest {
            return NetRequest(builder: self)
        }
        
    }
    
}

public struct Body {
    public let parameterEncoding: ParameterEncoding
    public let params: Parameters

    public init(parameterEncoding: ParameterEncoding, params: Parameters) {
        self.parameterEncoding = parameterEncoding
        self.params = params
    }
}

public enum Method {
    case get,
    post,
    put,
    delete,
    head,
    options,
    trace,
    patch,
    connect
}

public enum ParameterEncoding {
    case url, json, form
}
