//
//  User.swift
//  foodtruck-api
//
//  Created by iulian david on 7/16/17.
//
//

import Routing
import MongoKitten


struct User {
    
    
    static let collection = ConfigDB.sharedInstance.database["user"]
    
    
    var id: ObjectId
    var username: String
    var email: String
    
        /// The column names for `id` and `email` in the database
    static let idKey = "_id"
    static let emailKey = "email"
    static let usernameKey = "username"
    
    var document: Document {
        return [User.idKey : self.id,
                User.emailKey : self.username,
                User.usernameKey : self.email
        ]
    }
    
    var documenForSave: Document {
        return [
                User.usernameKey : self.username,
                User.emailKey : self.email
        ]
    }
    
    
    init(username: String, email: String) {
        self.id = ObjectId()
        self.username = username
        self.email = email
        
    }
    
    //retrieving a document from collection
    init(id: String) throws {
        let objectID = try ObjectId(id)
        
        let query: Query = "_id" == objectID
        
        guard let user = try User.collection.findOne(query) else {
            fatalError()
        }
        
//        guard let username =  user.dictionaryRepresentation["username"] as? String else {
//            fatalError()
//        }
        
        guard let username =  user[User.usernameKey] as? String else {
            fatalError()
        }
        
        guard let email =  user[User.emailKey] as? String else {
            fatalError()
        }
        
        self.id = objectID
        self.username = username
        self.email = email
    }
    
    // MARK: - CRUD
    func save() throws {
        
        let query: Query = "_id" == self.id
        // create or update current document
        try User.collection.update(query, to: self.documenForSave, upserting: true)
        
    }
    
    func delete() throws {
        try User.collection.remove("_id" == self.id)
    }
    
    func findAll() throws {
        
    }
    
    static func findById(id: String) throws -> Document {
        let objectID = try ObjectId(id)
        
        let query: Query = "_id" == objectID
        
        guard let user = try User.collection.findOne(query) else {
            throw Abort.badRequest
        }
        return user
    }
    
    static func findAll() throws -> Document {
        return Document(array: Array(try User.collection.find()))
    }
    
}

extension ObjectId : StringInitializable {
    public init?(from string: String) throws {
        try self.init(string)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new User (POST /user)
//     - Fetching a post (GET /user, GET /user/:id)
//
extension User: JSONConvertible {
    init(json: JSON) throws {
        try self.init(
            username: json.get(User.usernameKey),
            email: json.get(User.emailKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        print("id is \(id)")
      //  try json.set(User.idKey, id)
        try json.set(User.emailKey, email)
        try json.set(User.usernameKey, username)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable {
    func makeResponse() throws -> Response {
        guard let json = try? self.makeJSON() else {
            throw Abort(.notFound, reason: "No \(self) with that identifier was found.")
        }
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: json)
    }
}


extension User: Parameterizable {
    /// the unique key to use as a slug in route building
    public static var uniqueSlug: String {
        return idKey
    }
    
    // returns the found model for the resolved url parameter
    public static func make(for parameter: String) throws -> User {

        guard let found = try? User.init(id: parameter) else {
            throw Abort(.notFound, reason: "No \(self) with that identifier was found.")
        }
        return found
    }
}

extension Request {
    /// Create a user from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
}
}
