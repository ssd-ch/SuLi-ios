//
//  StringExtension.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/20.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation

extension String {
    
    //正規表現で文字列の削除を行う
    func replaceAll(pattern: String, with: String) -> String {
        return self.replacingOccurrences(of: pattern, with: with, options: NSString.CompareOptions.regularExpression, range: nil)
    }
    
    private func convertFullWidthToHalfWidth(reverse: Bool) -> String {
        let str = NSMutableString(string: self) as CFMutableString
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, reverse)
        return str as String
    }
    
    var hankaku: String {
        return convertFullWidthToHalfWidth(reverse: false)
    }
    
    var zenkaku: String {
        return convertFullWidthToHalfWidth(reverse: true)
    }
    
    //全角数字を半角数字に変換する
    private func convertFullWidthToHalfWidthOnlyNumber(fullWidth: Bool) -> String {
        var str = self
        let pattern = fullWidth ? "[0-9]+" : "[０-９]+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: str, options: [], range: NSMakeRange(0, str.characters.count))
        
        results.reversed().forEach {
            let subStr = (str as NSString).substring(with: $0.range)
            str = str.replacingOccurrences(of: subStr, with: (fullWidth ? subStr.zenkaku : subStr.hankaku))
        }
        return str
    }
    
    var HalfWidthNumber: String {
        return convertFullWidthToHalfWidthOnlyNumber(fullWidth: false)
    }
    
    var FullWidthNumber: String {
        return convertFullWidthToHalfWidthOnlyNumber(fullWidth: true)
    }
    
    //絵文字など(2文字分)も含めた文字数を返す
    var count: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    //正規表現の検索する
    func matches(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.count > 0
    }
    
    //区切る文字
    static let separeteCharacter = ","
    
    //正規表現で一致した文字列を返す(複数の場合はsepareCharacterで区切る)
    func matcherSubString(pattern: String, options: NSRegularExpression.Options = []) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return ""
        }
        let targetStringRange = NSRange(location: 0, length: self.count)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        var matches = ""
        for i in 0 ..< results.count {
            for j in 0 ..< results[i].numberOfRanges {
                let range = results[i].rangeAt(j)
                matches.append((self as NSString).substring(with: range) + String.separeteCharacter)
            }
        }
        return matches.replaceAll(pattern: ",$", with: "")
    }
}
