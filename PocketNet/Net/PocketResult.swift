public enum PocketResult<T, Error> {
    case success(T)
    case failure(Error)
    
    init(failure: Error) {
        self = .failure(failure)
    }

    init(success: T) {
        self = .success(success)
    }

    var successValue: T? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    var failureValue: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }

    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    var isFailure: Bool {
        switch self {
        case .success: return false
        case .failure: return true
        }
    }

}
