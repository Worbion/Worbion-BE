//
//  FullNameValidator.swift
//
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - FullNameValidator
struct FullNameValidator: ValidatorResult {
    private var fullNameStr: String
        
    var isFailure: Bool {
        return !doValidateFullName()
    }
    
    var successDescription: String? {
        return nil
    }
    
    var failureDescription: String? {
        return "\(fullNameStr) is not valid FullName."
    }
    
    init(fullNameStr: String) {
        self.fullNameStr = fullNameStr
    }
}

extension FullNameValidator {
    func doValidateFullName() -> Bool {
        let trimmedName = fullNameStr.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let words = trimmedName.split(separator: " ")
        
        guard words.count >= 2 else { return false }
        
        // insert turkish chars
        var letterCharacterSet = CharacterSet.letters
        letterCharacterSet.insert(charactersIn: "çğıöşüÇĞİÖŞÜ")
        
        for word in words {
            if word.rangeOfCharacter(from: letterCharacterSet.inverted) != nil {
                return false
            }
        }
        return true
    }
}
