//
//  URLEncoding.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/05.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

extension String.Encoding {
    static let windows31j = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosJapanese.rawValue)))
}

extension String {
    func addingPercentEncoding(withAllowedCharacters characterSet: CharacterSet, using encoding: String.Encoding) -> String {
        let stringData = self.data(using: encoding, allowLossyConversion: true) ?? Data()
        let percentEscaped = stringData.map {byte->String in
            if characterSet.contains(UnicodeScalar(byte)) {
                return String(UnicodeScalar(byte))
            } else if byte == UInt8(ascii: " ") {
                return "+"
            } else {
                return String(format: "%%%02X", byte)
            }
            }.joined()
        return percentEscaped
    }
    
    var sjisPercentEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved,  using: .windows31j)
    }
}

//let escaped = "今時SJISのシステムなんて…".sjisPercentEncoded
//print(escaped) //->%8D%A1%8E%9ESJIS%82%CC%83V%83X%83e%83%80%82%C8%82%F1%82%C4%81c
