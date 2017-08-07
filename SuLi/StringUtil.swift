//
//  StringUtil.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/20.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation

extension String {
    
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
}
