import Vapor
import HTTP


final class TestController {
    func addRoutes(drop: Droplet) {
        
        // Adding a prefix to routes
        let api = drop.grouped("api/v1")
        api.get("query", handler: query)
    }


    // MARK: - API Route
    func query(request: Request) throws -> ResponseRepresentable {
        let results =  try Post.makeQuery()
        
       
        return try JSON(node: [])
    }
}
