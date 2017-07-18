import Vapor
import FluentProvider
import HTTP
import Authentication
import Validation
import BCrypt


final class User: Model {
    let storage = Storage()
    
    /// User name with validator
    var name: String
    /// email with validator
    var email: String
    /// The user's _hashed_ password
    var password: String?

    /// The column names for `id` and `content` in the database
    static let idKey = "_id"
    static let nameKey = "name"
    static let emailKey = "email"
    static let passwordKey = "password"

     /// Creates a new User
    init(name: String, email: String, rawPassword: String? = nil) throws {
        try Name().validate(name)
        self.name = name
        try EmailValidator().validate(email)
        self.email = email
        // // validate the password
        // try PasswordValidator().validate(rawPassword)
        // encrypt it
        self.password = rawPassword
    }

    // MARK: Row
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name = try row.get(User.nameKey)
        email = try row.get(User.emailKey)
        password = try row.get(User.passwordKey)
    }

    // Serializes the User to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.nameKey, name)
        try row.set(User.emailKey, email)
        try row.set(User.passwordKey, password)
        return row
    }
}

// MARK: Preparation
extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.nameKey)
            builder.string(User.emailKey)
            builder.string(User.passwordKey)
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
//     - Creating a new User (POST /users)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(User.nameKey),
            email: json.get(User.emailKey)
        )
        id = try json.get(User.idKey)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.idKey, id?.string)
        try json.set(User.nameKey, name)
        try json.set(User.emailKey, email)
        return json
    }
}

// MARK: HTTP
// This allows User models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

// MARK: Password
// This allows the User to be authenticated
// with a password. We will use this to initially
// login the user so that we can generate a token.
extension User: PasswordAuthenticatable {
    var hashedPassword: String? {
        return password
    }

    public static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
}
// store private variable since storage in extensions
// is not yet allowed in Swift
private var _userPasswordVerifier: PasswordVerifier? = nil


// MARK: Request
extension Request {
    /// Convenience on request for accessing
    /// this user type.
    /// Simply call `let user = try req.user()`.
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

// MARK: Token
// This allows the User to be authenticated
// with an access token.
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}