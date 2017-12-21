import UIKit
import Alamofire

class CustomServerTrustPolicyManager: ServerTrustPolicyManager {

    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        if let policy = super.serverTrustPolicy(forHost: host) {
            print(policy)
            return policy
        } else {
            return .customEvaluation({ (_, _) -> Bool in
                return false
            })
        }
    }
    
}
