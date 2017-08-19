import Vapor
import HTTP
import Configs

final class TestController {
    
//    let storage = Storage()
    
    func addRoutes(drop: Droplet) {
        
        // Adding a prefix to routes
        let api = drop.grouped("api/v1")
        api.get("query", handler: query)
    }


    // MARK: - API Route
    func query(request: Request) throws -> ResponseRepresentable {
//        let results =  try Post.makeQuery()
//       log.debug(storage["vapor:providers"] as? [Provider])
       log.debug(config.providers)
        return try JSON(node: [])
    }
}
