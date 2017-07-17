import Vapor
import MongoKitten

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
        
    
//        print(config["server", "securityLayer"]?.string ?? "gherle")
        try resource("posts", PostController.self)
        try resource("users", UserController.self)
        
    }
}
