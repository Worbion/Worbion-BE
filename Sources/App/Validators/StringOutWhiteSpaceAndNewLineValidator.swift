//
//  StringOutWhiteSpaceAndNewLineValidator.swift
//
//
//  Created by Cemal on 24.08.2024.
//

import Foundation

// " Cemal Tuysuz" -> valid
// "Ankara Caddesi " -> valid
// "+1034030934\n" -> valid
// "jhon doe" -> failure

struct StringOutWhiteSpaceAndNewLineValidator {
    let string: String
    
    init(string: String) {
        self.string = string
    }
}

// MARK: - StringOutWhiteSpaceAndNewLineValidator
extension StringOutWhiteSpaceAndNewLineValidator: BaseValidatorResult {
    var failureDescription: String? {
        return "\(string) has no white space or new line at start and end."
    }
    
    func doValidate() -> Bool {
        let hasLeadingWhitespaceOrNewline = string.hasPrefix(" ") || string.hasPrefix("\n")
        let hasTrailingWhitespaceOrNewline = string.hasSuffix(" ") || string.hasSuffix("\n")
        
        return hasLeadingWhitespaceOrNewline || hasTrailingWhitespaceOrNewline
    }
}
