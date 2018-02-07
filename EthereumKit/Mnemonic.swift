//
//  Mnemonic.swift
//  EthereumKit
//
//  Created by yuzushioh on 2018/01/01.
//  Copyright © 2018 yuzushioh.
//

import Foundation

public final class Mnemonic {
    public static func create(entropy: String, language: WordList = .english) -> String {
        let initialEntropy = entropy.mnemonicData
        
        let acceptableEntropyLengthList = [16, 20, 24, 28, 32]
        guard acceptableEntropyLengthList.contains(initialEntropy.count) else {
            fatalError("Initial entropy data length should be one of the following: \(acceptableEntropyLengthList). It is \(initialEntropy.count)")
        }
        
        let initialEntropyBits = initialEntropy.toBits
        let checkSumDistance = 0..<(initialEntropyBits.count / 32)
        let checkSum = initialEntropy.sha256().toBits[checkSumDistance]
        
        let entropyBits = initialEntropyBits + checkSum
        let splittingInterval = 11
        guard entropyBits.count % splittingInterval == 0 else {
            fatalError("Entropy data length mush be in a multiple of \(splittingInterval).")
        }
        
        let words = language.words
        let estimatedWordCount = entropyBits.count / splittingInterval
        
        var mnemonic: [String] = []
        for index in 0..<estimatedWordCount {
            let startIndex = index * splittingInterval
            let endIndex = startIndex + splittingInterval
            let subArray = entropyBits[startIndex..<endIndex]
            let subString = subArray.joined(separator: "")
            
            let wordIndex = Int(strtoul(subString, nil, 2))
            mnemonic.append(words[wordIndex])
        }
        
        return mnemonic.joined(separator: " ")
    }
    
    public static func createSeed(mnemonic: String, withPassphrase passphrase: String = "") -> Data {
        guard let password = mnemonic.data(using: .utf8, allowLossyConversion: true)?.bytes else {
            fatalError("Nomalizing password failed in \(self)")
        }
        
        guard let salt = ("mnemonic" + passphrase).data(using: .utf8, allowLossyConversion: true)?.bytes else {
            fatalError("Nomalizing salt failed in \(self)")
        }
        
        return Crypto.PBKDF2SHA512(password: password, salt: salt)
    }
}
