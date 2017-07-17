import Vapor
import FluentProvider
import HTTP

final class Post: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var content: String
    
    /// Another column
    var obs: String
    
    /// The column names for `id` and `content` in the database
    static let idKey = "_id"
    static let contentKey = "content"
    static let obsKey = "obs"

    /// Creates a new Post
    init(content: String, obs: String) {
        self.content = content
        self.obs = obs
    }

    // MARK: Fluent Serialization

    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        content = try row.get(Post.contentKey)
        obs = try row.get(Post.obsKey)
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.contentKey, content)
        try row.set(Post.obsKey, obs)
        return row
    }
}

// MARK: Fluent Preparation

extension Post: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.contentKey)
            builder.string(Post.obsKey)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            content: json.get(Post.contentKey),
            obs: json.get(Post.obsKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.idKey, id?.string)
        try json.set(Post.contentKey, content)
        try json.set(Post.obsKey, obs)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Post: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Post: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Post.contentKey, String.self) { post, content in
                post.content = content
            },
            UpdateableKey(Post.obsKey, String.self) { post, obs in
                post.obs = obs
            }
        ]
    }
}
