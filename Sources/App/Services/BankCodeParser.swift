//
//  BankCodeParser.swift
//
//
//  Created by Cemal on 8.09.2024.
//

import Foundation

// MARK: - BankCodeParser
struct BankCodeParser {
    /// Get bank code from iban number
    static func parse(from iban: String) -> String? {
        guard iban.count >= 10 else { return nil }
        
        let startIndex = iban.index(iban.startIndex, offsetBy: 4)
        let endIndex = iban.index(startIndex, offsetBy: 5)
        return String(iban[startIndex..<endIndex])
    }
}
