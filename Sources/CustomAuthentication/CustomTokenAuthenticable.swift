//
//  CustomTokenAuthenticable.swift
//  foodtruck-api
//
//  Created by iulian david on 7/19/17.
//
//
import Foundation
import Authentication

public protocol CustomTokenAuthenticable: Authenticatable {
    
    /// The token entity that contains a foreign key
    /// pointer to the user table (or on the user table itself)
    associatedtype TokenType
    
    // MARK:  AccessToken / RefreshToken
    /// Return the user matching the supplied
    /// accessToken if the user exists and token not expired
    static func authenticate(_: String) throws -> Self
    
    
    /// The key under which the user's access token or other identifing value is stored.
    static var accessTokenKey: String { get }
    
    /// The key under which the user's refresh token
    /// is stored.
    static var refreshTokenKey: String { get }
    
    /// The key under which the user's token expiry date
    /// is stored.
    static var expiryDateKey: String { get }
    
}

extension CustomTokenAuthenticable {
    public static var accessTokenKey: String {
        return "accessToken"
    }
    
    public static var refreshTokenKey: String {
        return "refreshToken"
    }
    
    public static var expiryDateKey: String {
        return "expiryDate"
    }
}



// MARK: Entity conformance

import Fluent

extension CustomTokenAuthenticable where Self: Entity, Self.TokenType: Entity {
    public static func authenticate(_ token: String) throws -> Self {
        let user: Self
        
        guard let _ = try Self.TokenType.makeQuery()
            .filter(accessTokenKey, token)
            .filter(expiryDateKey, Filter.Comparison.greaterThanOrEquals, Date())
            .first()
            else {
                throw AuthenticationError.unspecified(CustomAuthenticationError.accessTokenExpired)
        }
        
        
        guard let foundUser = try Self.makeQuery()
            .join(Self.TokenType.self)
            .filter(Self.TokenType.self, accessTokenKey, token)
            .first()
            else {
                throw AuthenticationError.invalidCredentials
        }
        user = foundUser
        
        return user
        
    }
}
