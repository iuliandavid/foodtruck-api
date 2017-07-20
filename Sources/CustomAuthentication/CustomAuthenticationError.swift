//
//  CustomAuthenticationError.swift
//  foodtruck-api
//
//  Created by iulian david on 7/19/17.
//
//

import Debugging

public enum CustomAuthenticationError: Error {
    case accessTokenExpired
    case invalidRefreshToken
    case unspecified(Error)
}

extension CustomAuthenticationError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        let reason: String
        switch self {
        case .accessTokenExpired:
            reason = "Access Token Has Expired"
        case .invalidRefreshToken:
            reason = "Invalid Refresh Token"
        case .unspecified(let error):
            reason = "\(error)"
        }
        return reason
    }
}
