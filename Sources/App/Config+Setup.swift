import SwiftyBeaverProvider
import FluentProvider
import MongoProvider
import AuthProvider



extension Config {
    // TODO - see if it will be needed
    
    public func getConfig() -> Config {
        return config
    }
    
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MongoProvider.Provider.self)
        try addProvider(SwiftyBeaverProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(User.self)
        preparations.append(Token.self)
    }
}


