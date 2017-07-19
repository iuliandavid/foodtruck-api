import Authentication
import Foundation

// MARK: Data structure
public struct CustomToken: Credentials {
    public let accessToken: String
    public let refreshToken: String
    public let expiryDate: Date
    
    public init(accessToken: String, refreshToken: String, expiryDate: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiryDate = expiryDate
    }
}
