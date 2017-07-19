////
////  MyTokenAuthenticationMiddleware.swift
////  foodtruck-api
////
////  Created by iulian david on 7/19/17.
////
////
//
//import Foundation
//
//import HTTP
//import Authentication
//// MARK: Entity conformance
//
//import Fluent
//
///// Requires a `Authorization: Bearer ...` header and authenticates
///// the supplied User type using the `TokenAuthenticatable` protocol.
//public final class MyTokenAuthenticationMiddleware<U: MyTokenProtocolAuthenticatable>: Middleware {
//    public init(_ userType: U.Type = U.self) {}
//    
//    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
//        // if the user has already been authenticated
//        // by a previous middleware, continue
//        if req.auth.isAuthenticated(U.self) {
//            return try next.respond(to: req)
//        }
//        
//        guard let token = req.auth.header?.bearer else {
//            throw AuthenticationError.invalidCredentials
//        }
//        
//        let u = try U.authenticate(token)
//        
//        req.auth.authenticate(u)
//        
//        return try next.respond(to: req)
//    }
//}
//
//
//
//public protocol MyTokenProtocolAuthenticatable: Authenticatable {
//    /// The token entity that contains a foreign key
//    /// pointer to the user table (or on the user table itself)
//    associatedtype TokenType
//    
//    /// Returns the user matching the supplied token.
//    static func authenticate(_ token: Token) throws -> Self
//    
//    /// The column under which the tokens are stored
//    static var tokenKey: String { get }
//}
//
//extension MyTokenProtocolAuthenticatable {
//    public static var tokenKey: String {
//        return "accessToken"
//    }
//}
//
//
//
//extension MyTokenProtocolAuthenticatable where Self: Entity, Self.TokenType: Entity {
//    internal static func authenticate(_ token: Token) throws -> Self {
//        guard let user = try Self.makeQuery()
//            .join(Self.TokenType.self)
//            .filter(Self.TokenType.self, tokenKey, token.accessToken)
//            .first()
//            else {
//                throw AuthenticationError.invalidCredentials
//        }
//        
//        return user
//    }
//}
//
//extension MyTokenProtocolAuthenticatable where Self: Entity, Self.TokenType: Entity, Self.TokenType == Self {
//    internal static func authenticate(_ token: Token) throws -> Self {
//        guard let user = try Self.makeQuery()
//            .filter(tokenKey, token.accessToken)
//            .first()
//            else {
//                throw AuthenticationError.invalidCredentials
//        }
//        
//        return user
//    }
//}
