//
//  CustomTokenAuthenticable.swift
//  foodtruck-api
//
//  Created by iulian david on 7/19/17.
//
//

import Authentication

public protocol CustomTokenAuthenticable: Authenticatable {
    /// The token entity that contains a foreign key
    /// pointer to the user table (or on the user table itself)
    associatedtype TokenType
    // MARK:  AccessToken / RefreshToken
    /// Return the user matching the supplied
    /// accessToken and refreshToken
    static func authenticate(_: String) throws -> Self
    
    
    /// The key under which the user's access token or other identifing value is stored.
    static var accessKey: String { get }
    
    /// The key under which the user's refresh token
    /// is stored.
    static var refreshKey: String { get }
    
    /// The key under which the user's token expiry date
    /// is stored.
    static var expiryKey: String { get }
    
}

extension PasswordAuthenticatable {
    public static var accessKey: String {
        return "accessToken"
    }
    
    public static var refreshKey: String {
        return "refreshToken"
    }
    
    public static var expiryKey: String {
        return "expiryDate"
    }
}



// MARK: Entity conformance

import Fluent

extension CustomTokenAuthenticable where Self: Entity, Self.TokenType: Entity {
    public static func authenticate(_ token: String) throws -> Self {
        let user: Self
        log.debug("input token \(token)")
        
        guard let foundToken = try Self.TokenType.makeQuery()
            .filter(accessKey, token)
            .first() as? Token, foundToken.expiryDate.timeIntervalSinceNow >= 0
            else {
                throw AuthenticationError.unspecified(CustomAuthenticationError.accessTokenExpired)
        }
        
        log.debug("token found: \(foundToken)")
        
        guard let foundUser = try Self.makeQuery()
            .join(Self.TokenType.self)
            .filter(Self.TokenType.self, accessKey, token)
            .first()
            else {
                throw AuthenticationError.invalidCredentials
        }
        user = foundUser
        
        return user

    }
}
