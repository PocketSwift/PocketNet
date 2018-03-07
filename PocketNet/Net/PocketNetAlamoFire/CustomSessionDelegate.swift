import UIKit

class CustomSessionDelegate: SessionDelegate {
    
    let resourceURL: URL
    
    init?(resourceURL: URL) {
        self.resourceURL = resourceURL
        super.init()
        sessionDidReceiveChallengeWithCompletion = { session, challenge, completion in
            guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
                completion(.cancelAuthenticationChallenge, nil)
                return
            }
            if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0), let serverCertificateKey = CustomSessionDelegate.publicKey(for: serverCertificate) {
                if CustomSessionDelegate.pinnedKeys(resourceURL: self.resourceURL).contains(serverCertificateKey) {
                    completion(.useCredential, URLCredential(trust: trust))
                    return
                }
            }
            completion(.cancelAuthenticationChallenge, nil)
        }
    }
    
    private static func pinnedKeys(resourceURL: URL) -> [SecKey] {
        var publicKeys: [SecKey] = []
        do {
            let pinnedCertificateData = try Data(contentsOf: resourceURL) as CFData
            if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData), let key = publicKey(for: pinnedCertificate) {
                publicKeys.append(key)
            }
        } catch (_) {}
        return publicKeys
    }
    
    private static func publicKey(for certificate: SecCertificate) -> SecKey? {
        var publicKey: SecKey?
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        if let trust = trust, trustCreationStatus == errSecSuccess {
            publicKey = SecTrustCopyPublicKey(trust)
        }
        return publicKey
    }

}
