import SwiftyBeaver

//setup the logger
let log = SwiftyBeaver.self


let config: Config = {
    let config = try! Config()
    let console = ConsoleDestination()  // log to Xcode Console
    log.addDestination(console)
    return config
}()


extension Config {
    // TODO - see if it will be needed
    
    public func getConfig() -> Config {
        return config
    }
}


