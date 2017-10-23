import Foundation

public protocol Convertible {
    static func instance<T: Convertible>(_ jsonString: String) -> T?
    func getJSONString() -> String?
}
