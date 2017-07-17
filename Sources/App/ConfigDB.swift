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
    
    //    //setup Mongo
    //    fileprivate func setupMongo() -> Database? {
    //
    //        return database
    //    }
    
    private init() {
        var newdatabase: Database?
        
        log.info("host from config: \(config["servers", "mongodb", "host"]?.string ?? "gherle")")
        guard let mongo_host = config["servers", "mongodb", "host"]?.string, let mongo_port = config["servers", "mongodb", "port"]?.string,
        let mongo_db = config["servers", "mongodb", "host"]?.string else {
            fatalError()
        }
        do {
            let server = try Server("mongodb://\(mongo_host):\(mongo_port)/")
            if server.isConnected {
                print("Successfully connected!")
            } else {
                print("Connection failed")
            }
            newdatabase = server[mongo_db]
        } catch {
            fatalError()
        }
        database = newdatabase!
    }
    
    
}
