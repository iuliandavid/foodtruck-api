import Vapor
import Validation

class PasswordValidator: Validator {

    public func validate(_ value: String) throws {
        // Password should contain at least 1 number and at least one upperCase character
        let range = value.range(of: "^(?=.*[0-9])(?=.*[A-Z])", options: .regularExpression)

        guard let _ = range else {
            throw error(value)
        }
        
        
        try value.validated(by: Count.min(6) && Count.max(64)) 
    }
}