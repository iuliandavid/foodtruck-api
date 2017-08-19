import MongoKitten
import SwiftyBeaver


//setup the logger
let log = SwiftyBeaver.self


let config: Config = {
    let config = try! Config()
    let console = ConsoleDestination()  // log to Xcode Console
    log.addDestination(console)
    return config
}()

final class ConfigDB {
    
    static let sharedInstance = ConfigDB()
    
    
    let database:Database
    
    
    private init() {
        
        var newdatabase: Database?
        
         guard let mongo_db = config["servers", "mongodb", "host"]?.string else {
             fatalError()
         }
        guard let mongo_url = config["mongo", "url"]?.string else {
            fatalError()
        }
        do {
            let server = try Server(mongo_url)
            if server.isConnected {
                log.info("Successfully connected!")
            } else {
                log.error("Connection failed")
            }
            newdatabase = server[mongo_db]
        } catch {
            fatalError()
        }
        database = newdatabase!
    }
    
    
}
