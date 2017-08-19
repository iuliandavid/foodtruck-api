import Vapor
import MongoKitten
import AuthProvider
import Routing
import CustomAuthentication

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
    
        try resource("posts", PostController.self)
        let tests = TestController()
        tests.addRoutes(drop: self)
        
//        try resource("users", UserOldController.self)
        
        try setupUnauthenticatedRoutes()
        try setupPasswordProtectedRoutes()
        try setupTokenProtectedRoutes()
    }

    private func setupUnauthenticatedRoutes() throws {
        // create a new user
        //
        // POST /users
        // <json containing new user information>
        post("users") { req in
            // require that the request body be json
            guard let json = req.json else {
                throw Abort(.badRequest)
            }

            // initialize the name and email from
            // the request json
            let user = try User(json: json)

            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }

            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }

            // hash the password and set it on the user
            user.password = try self.hash.make(password.makeBytes()).makeString()

            // save and return the new user
            try user.save()
            return user
        }
        
        // get a new access token
        //
        // POST /users/authorize/refresh_token
        // <json containing the user email and the refresh token>
        post("users","authorize","refresh_token") { req in
            guard let json = req.json, let email = try? json.get("email") as String, let refreshToken = try? json.get("refresh_token") as String else {
                throw Abort.badRequest
            }
            
            guard let foundToken = try CustomToken.makeQuery().filter(CustomToken.self, "refreshToken", refreshToken)
                .first() else {
                    throw AuthenticationError.unspecified(CustomAuthenticationError.invalidRefreshToken)
            }
            
            // ensure a user with this email exists
            guard let foundUser = try foundToken.user.get(), foundUser.email == email else {
                throw AuthenticationError.invalidCredentials
            }
            
            return try self.generateNewToken(foundUser)

        }
    }


    /// Sets up all routes that can be accessed using
    /// username + password authentication.
    /// Since we want to minimize how often the username + password
    /// is sent, we will only use this form of authentication to
    /// log the user in.
    /// After the user is logged in, they will receive a token that
    /// they can use for further authentication.
    private func setupPasswordProtectedRoutes() throws {
        // creates a route group protected by the password middleware.
        // the User type can be passed to this middleware since it
        // conforms to PasswordAuthenticatable
        let password = grouped([
            PasswordAuthenticationMiddleware(User.self)
        ])

        // verifies the user has been authenticated using the password
        // middleware, then generates, saves, and returns a new access token.
        //
        // POST /login
        // Authorization: Basic <base64 email:password>
        password.post("login") { req in
            let user = try req.user()
            
            return try self.generateNewToken(user)
        }
    }

    /// Sets up all routes that can be accessed using
    /// the authentication token received during login.
    /// All of our secure routes will go here.
    private func setupTokenProtectedRoutes() throws {
        // creates a route group protected by the token middleware.
        // the User type can be passed to this middleware since it
        // conforms to TokenAuthenticatable
       
        let tokenGroup = grouped([CustomTokenMiddleware(User.self)]).grouped("api/v1")
        

        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // GET /me
        // Authorization: Bearer <token from /login>
       
        tokenGroup.get("profile/me") { req in
            let user = try req.user()
            return "Hello, \(user.name)"
        }
        try tokenGroup.resource("users", UserOldController.self)
    }
    
    private func generateNewToken(_ user: User) throws -> CustomToken {
        //delete all the refresh token
        let tokens = try CustomToken.makeQuery().filter("user__id", user.id?.string).all()
        for deletableToken in tokens {
            try deletableToken.delete()
        }
        let token = try CustomToken.generate(for: user)
        try token.save()
        return token
    }
}
