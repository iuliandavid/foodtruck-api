
import Foundation
import Vapor
import FluentProvider
import Crypto

final class Token: Model {
    let storage = Storage()

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
        expiryDate = calendar.date(byAdding: .second, value: Token.EXPIRE_SECONDS, to: Date())!
        //TODO : test expiry date 
        // Date().timeIntervalSince(expiryDate) > 5 minutes
        userId = try user.assertExists()
    }

    // MARK: Row
    init(row: Row) throws {
        self.refreshToken = try row.get(Token.refreshTokenKey)
        self.accessToken = try row.get(Token.accessTokenKey)
        userId = try row.get(User.foreignIdKey)
        expiryDate = try row.get(Token.expiryDateKey)

    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Token.accessTokenKey, self.accessToken)
        try row.set(Token.refreshTokenKey, self.refreshToken)
        try row.set(Token.expiryDateKey, self.expiryDate)
        try row.set(User.foreignIdKey, userId)
        return row
    }
}

// MARK: Convenience
extension Token {
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> Token {
        // generate 128 random bits using OpenSSL
        let random1 = try Crypto.Random.bytes(count: 16)

        // generate 128 random bits using OpenSSL
        let random2 = try Crypto.Random.bytes(count: 18)

        // create and return the new token
        return try Token(accessToken: random1.base64Encoded.makeString(),refreshToken: random2.base64Encoded.makeString(), user: user)
    }
}


// MARK: Relations
extension Token {
    /// Fluent relation for accessing the user
    var user: Parent<Token, User> {
        return parent(id: userId)
    }
}

// MARK: Preparation
extension Token: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Tokens
    static func prepare(_ database: Database) throws {
        try database.create(Token.self) { builder in
            builder.id()
            builder.string(Token.accessTokenKey)
            builder.string(Token.refreshTokenKey)
            builder.string(Token.expiryDateKey)
            builder.foreignId(for: User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(Token.self)
    }
}


// MARK: JSON
/// Allows the token to convert to JSON.
extension Token: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Token.accessTokenKey, accessToken)
        try json.set(Token.refreshTokenKey, refreshToken)
        try json.set(Token.expiryDateKey, expiryDate)
        return json
    }
}

// MARK: HTTP
/// Allows the Token to be returned directly in route closures.
extension Token: ResponseRepresentable { }

extension Token: CustomDebugStringConvertible {
         var debugDescription: String {
             return "Token(accessToken: \(accessToken), refreshToken: \(refreshToken), expiryDate: \(expiryDate))"
         }
     }
