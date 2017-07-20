
import Foundation
import Vapor
import FluentProvider
import Crypto

final class CustomToken: Model {
    let storage = Storage()

    static var entity = "tokens"
    /// The access token
    var accessToken: String
    /// The refresh token
    var refreshToken: String
    /// The creation date
    var expiryDate: Date

    /// The identifier of the user to which the token belongs
    let userId: Identifier


    /// The column names for `id` and `content` in the database
    static let idKey = "_id"
    static let accessTokenKey = "accessToken"
    static let refreshTokenKey = "refreshToken"
    static let expiryDateKey = "expiryDate"
    
    static let EXPIRE_SECONDS = 30 * 60;
    /// Creates a new Token
    init(accessToken: String, refreshToken: String, user: User) throws {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        let calendar = Calendar.current
        expiryDate = calendar.date(byAdding: .second, value: CustomToken.EXPIRE_SECONDS, to: Date())!
        //TODO : test expiry date 
        // Date().timeIntervalSince(expiryDate) > 5 minutes
        userId = try user.assertExists()
    }

    // MARK: Row
    init(row: Row) throws {
        self.refreshToken = try row.get(CustomToken.refreshTokenKey)
        self.accessToken = try row.get(CustomToken.accessTokenKey)
        userId = try row.get(User.foreignIdKey)
        expiryDate = try row.get(CustomToken.expiryDateKey)

    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(CustomToken.accessTokenKey, self.accessToken)
        try row.set(CustomToken.refreshTokenKey, self.refreshToken)
        try row.set(CustomToken.expiryDateKey, self.expiryDate)
        try row.set(User.foreignIdKey, userId)
        return row
    }
}

// MARK: Convenience
extension CustomToken {
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> CustomToken {
        // generate 128 random bits using OpenSSL
        let random1 = try Crypto.Random.bytes(count: 16)

        // generate 128 random bits using OpenSSL
        let random2 = try Crypto.Random.bytes(count: 18)

        // create and return the new token
        return try CustomToken(accessToken: random1.base64Encoded.makeString(),refreshToken: random2.base64Encoded.makeString(), user: user)
    }
}


// MARK: Relations
extension CustomToken {
    /// Fluent relation for accessing the user
    var user: Parent<CustomToken, User> {
        return parent(id: userId)
    }
}

// MARK: Preparation
extension CustomToken: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Tokens
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(CustomToken.accessTokenKey)
            builder.string(CustomToken.refreshTokenKey)
            builder.string(CustomToken.expiryDateKey)
            builder.foreignId(for: User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(CustomToken.self)
    }
}


// MARK: JSON
/// Allows the token to convert to JSON.
extension CustomToken: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(CustomToken.accessTokenKey, accessToken)
        try json.set(CustomToken.refreshTokenKey, refreshToken)
        try json.set(CustomToken.expiryDateKey, expiryDate)
        return json
    }
}

// MARK: HTTP
/// Allows the Token to be returned directly in route closures.
extension CustomToken: ResponseRepresentable { }

extension CustomToken: CustomDebugStringConvertible {
         var debugDescription: String {
             return "Token(accessToken: \(accessToken), refreshToken: \(refreshToken), expiryDate: \(expiryDate))"
         }
     }
