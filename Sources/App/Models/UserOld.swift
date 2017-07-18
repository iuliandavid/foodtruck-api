//
//  User.swift
//  foodtruck-api
//
//  Created by iulian david on 7/16/17.
//
//

import Routing
import MongoKitten


struct UserOld {
    
    
    static let collection = ConfigDB.sharedInstance.database["old_user"]
    
    
    var id: ObjectId
    var username: String
    var email: String
    
        /// The column names for `id` and `email` in the database
    static let idKey = "_id"
    static let emailKey = "email"
    static let usernameKey = "username"
    
    var document: Document {
        return [UserOld.idKey : self.id,
                UserOld.emailKey : self.username,
                UserOld.usernameKey : self.email
        ]
    }
    
    var documenForSave: Document {
        return [
                UserOld.usernameKey : self.username,
                UserOld.emailKey : self.email
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
        
        guard let user = try UserOld.collection.findOne(query) else {
            fatalError()
        }
        
//        guard let username =  user.dictionaryRepresentation["username"] as? String else {
//            fatalError()
//        }
        
        guard let username =  user[UserOld.usernameKey] as? String else {
            fatalError()
        }
        
        guard let email =  user[UserOld.emailKey] as? String else {
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
        try UserOld.collection.update(query, to: self.documenForSave, upserting: true)
        
    }
    
    func delete() throws {
        try UserOld.collection.remove("_id" == self.id)
    }
    
    func findAll() throws {
        
    }
    
    static func findById(id: String) throws -> Document {
        let objectID = try ObjectId(id)
        
        let query: Query = "_id" == objectID
        
        guard let user = try UserOld.collection.findOne(query) else {
            throw Abort.badRequest
        }
        return user
    }
    
    static func findAll() throws -> Document {

        let results = try UserOld.collection.find()
        
        let myResults = try results.map { $0 }
        log.info("results: \(myResults)")
        // if results.validatesAsArray() {
        //         let test = .array(results.arrayValue.map { $0.makeNode() })
        //         log.info("results: \(test)")
        //     }
        return Document(array: Array(try UserOld.collection.find()))
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
extension UserOld: JSONConvertible {
    init(json: JSON) throws {
        try self.init(
            username: json.get(UserOld.usernameKey),
            email: json.get(UserOld.emailKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        print("id is \(id)")
      //  try json.set(User.idKey, id)
        try json.set(UserOld.emailKey, email)
        try json.set(UserOld.usernameKey, username)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension UserOld: ResponseRepresentable {
    func makeResponse() throws -> Response {
        guard let json = try? self.makeJSON() else {
            throw Abort(.notFound, reason: "No \(self) with that identifier was found.")
        }
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: json)
    }
}


extension UserOld: Parameterizable {
    /// the unique key to use as a slug in route building
    public static var uniqueSlug: String {
        return idKey
    }
    
    // returns the found model for the resolved url parameter
    public static func make(for parameter: String) throws -> UserOld {

        guard let found = try? UserOld.init(id: parameter) else {
            throw Abort(.notFound, reason: "No \(self) with that identifier was found.")
        }
        return found
    }
}

extension Request {
    /// Create a user from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func userOld() throws -> UserOld {
        guard let json = json else { throw Abort.badRequest }
        return try UserOld(json: json)
}
}
