import Foundation

public typealias Parameters = [String: AnyObject]

public class RequestBuilder {

    public var url: String = ""
    public var method: Method = .get
    public var headers: [String: String] = [:]
    public var params: Parameters = [:]
    public var encoding: ParameterEncoding = .url
    public var shouldCache: Bool = true
    
    public init() { }

    public func setUrl(_ url: String) -> Self {
        self.url = url
        return self
    }
    
    public func method(_ method: Method) -> Self {
        self.method = method
        return self
    }

    public func addParameter(_ paramName: String, paramValue: String) -> Self {
        self.params[paramName] = paramValue as AnyObject?
        return self
    }
    
    public func addBody(params: String?) -> Self {
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

    public func setParameterEncoding(_ parameterEncoding: ParameterEncoding) -> Self {
        self.encoding = parameterEncoding
        return self
    }
    
    public func setRequestHeader(_ dicRequestHeader: [String: String]) -> Self {
        self.headers = dicRequestHeader
        return self
    }

    public func setShouldCache(_ shouldCache: Bool) -> Self {
        self.shouldCache = shouldCache
        return self
    }

    public func build () -> RequestNet {
        return RequestNet(builder: self)
    }

}
