import Foundation

public struct RequestNet {
    public let url: String
    public let method: Method
    public let shouldCache: Bool
    public let headers: [String: String]
    public let body: Body

    public init(builder: RequestBuilder) {
        self.url = builder.url
        self.method = builder.method
        self.shouldCache = builder.shouldCache
        self.headers = builder.headers
        self.body = Body(parameterEncoding: builder.encoding, params: builder.params)
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
