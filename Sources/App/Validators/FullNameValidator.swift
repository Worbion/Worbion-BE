//
//  FullNameValidator.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - FullNameValidator
struct FullNameValidator {
    private var fullNameStr: String
    
    init(
        fullNameStr: String
    ) {
        self.fullNameStr = fullNameStr
    }
}

// MARK: - BaseValidatorResult
extension FullNameValidator: BaseValidatorResult {
    
    var failureDescription: String? {
        return "\(fullNameStr) is not valid FullName."
    }
    
    func doValidate() -> Bool {
        guard StringOutWhiteSpaceAndNewLineValidator(string: fullNameStr).isFailure else { return false }
        // Trim whitespace from the start and end
        let trimmedName = fullNameStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split the name by spaces
        let nameComponents = trimmedName.split(separator: " ")
        
        // Check if there are at least two components (first and last name)
        guard nameComponents.count >= 2 else {
            return false
        }
        
        // Check each component for valid characters (letters, hyphens, apostrophes)
        let validCharacterSet = CharacterSet.letters.union(CharacterSet(charactersIn: "-'"))
        
        for component in nameComponents {
            if component.rangeOfCharacter(from: validCharacterSet.inverted) != nil {
                return false
            }
        }
        
        return true
    }
}
