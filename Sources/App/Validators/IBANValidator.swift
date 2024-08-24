//
//  IBANValidator.swift
//  
//
//  Created by Cemal on 30.07.2024.
//

import Vapor

// MARK: - IBANValidator
struct IBANValidator {
    private var ibanValueStr: String
    
    init(ibanValueStr: String) {
        self.ibanValueStr = ibanValueStr
    }
}

// MARK: - BaseValidatorResult
extension IBANValidator: BaseValidatorResult {
    
    var failureDescription: String? {
        return "\(ibanValueStr) is not valid IBAN."
    }
    
    func doValidate() -> Bool {
        guard StringOutWhiteSpaceAndNewLineValidator(string: ibanValueStr).isFailure else { return false }
        let ibanLength = 26
        
        let regex = try! NSRegularExpression(pattern: "^[A-Z]{2}[0-9]{2}[0-9A-Z]{22}$")
        let range = NSRange(location: 0, length: ibanValueStr.utf16.count)
        guard regex.firstMatch(in: ibanValueStr, options: [], range: range) != nil else {
            return false
        }
        
        guard ibanValueStr.count == ibanLength else {
            return false
        }
        
        let rearrangedIBAN = ibanValueStr.dropFirst(4) + ibanValueStr.prefix(4)
        
        let transformedIBAN = rearrangedIBAN.map { char -> String in
            if let digit = char.wholeNumberValue {
                return String(digit)
            } else if let scalar = char.unicodeScalars.first {
                return String(scalar.value - Unicode.Scalar("A").value + 10)
            }
            return String(char)
        }.joined()
        
        guard let mod97 = mod97Check(transformedIBAN) else {
            return false
        }
        
        return mod97 == 1
    }
    
    func mod97Check(_ digits: String) -> Int? {
        var remainder = 0
        for char in digits {
            guard let digit = Int(String(char)) else {
                return nil
            }
            remainder = (remainder * 10 + digit) % 97
        }
        return remainder
    }
}

