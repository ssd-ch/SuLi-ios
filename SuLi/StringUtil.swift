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
    
}
