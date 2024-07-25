//
//  RandomPasswordGenerator.swift
//
//
//  Created by Cemal on 23.07.2024.
//

import Foundation

// MARK: - RandomPasswordGenerator
struct RandomPasswordGenerator {
    let passwordCount: Int
}

extension RandomPasswordGenerator {
    public func generate() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let nums = "0123456789"
        
        let allChars = chars + nums
        var newPassword = ""
        
        for _ in 0..<passwordCount {
            let randomIndexValue = Int.random(in: 0..<allChars.count)
            let character = Array(allChars)[randomIndexValue]
            newPassword.append(character)
        }
        return newPassword
    }
}

