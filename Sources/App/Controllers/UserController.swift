import Vapor
import HTTP
import MongoKitten
import Cheetah

final class UserController: ResourceRepresentable {
    
        /// When consumers call 'POST' on '/posts' with valid JSON
        /// create and save the user
        func create(request: Request) throws -> ResponseRepresentable {
            let post = try request.user()
            try post.save()
//            return User.collection.findOne("_id" == post.id)
            guard let userDocument = try User.collection.findOne("_id" == post.id) else {
                throw Abort.badRequest
            }
            
            return userDocument
        }
    
        /// When the consumer calls 'GET' on a specific resource, ie:
        /// '/user/13rd88' we should show that specific post
        func show(req: Request, user: User) throws -> ResponseRepresentable {
            return user
        }
    
        /// When the consumer calls 'GET' on a specific resource, ie:
        /// '/user/13rd88' we should show that specific post
        func showWithHeader(req: Request) throws -> ResponseRepresentable {
            
            if let id = req.headers["id"]?.string{
                
                    return try User.findById(id: id)
               
            }else {
                return try User.findAll()
            }
            
        }

    
    func makeResource() -> Resource<User> {
                return Resource(
//                    index: index,
                    index: showWithHeader,
                    store: create,
                    show: show
//                    update: update,
//                    replace: replace,
//                    destroy: delete,
//                    clear: clear
                )
            }
    
}

extension Document : ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: .ok, headers: [
            "Content-Type": "application/json; charset=utf-8"
            ], body: Body(self.convert(toObject: JSONData.self).serialize()))
    }
}

extension Request {
    
    public var document: Document? {
        guard let bytes = self.body.bytes else {
            return nil
        }
        
        do {
            return try Document(extendedJSON: bytes)
        } catch {
            return nil
        }
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension UserController: EmptyInitializable { }
