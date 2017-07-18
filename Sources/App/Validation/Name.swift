import Vapor
import Validation

class Name: Validator {
    
    
    public func validate(_ input: String) throws {

        try input.validated(by: Count.min(6) && Count.max(64)) 
        // Name should contain at no number and at least one space
        let range = input.range(of: "^[a-z ,.'-]+$", options: [.regularExpression, .caseInsensitive])

        guard let _ = range else {
            throw error(input)
        }
    }

}
