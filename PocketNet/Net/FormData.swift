import Foundation

public class FormData {
    
    let apiName: String
    let fileName: String
    let mimeType: String
    let data: Data
    
    public init(apiName: String, fileName: String, mimeType: String, data: Data) {
        self.apiName = apiName
        self.fileName = fileName
        self.mimeType = mimeType
        self.data = data
    }
    
}
