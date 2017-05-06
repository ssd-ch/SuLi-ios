//
//  sjisHTTP.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/06.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import SwiftHTTP

open class sjisHTTP {
    
    open class func GET(_ url: String, parameters: [String:String]? = nil) throws -> HTTP  {
        if parameters != nil {
            var sjisURL: String = url + "?"
            for (key, value) in parameters!{
                sjisURL.append("\(key)=\(value.sjisPercentEncoded)&")
            }
            return try HTTP.GET(sjisURL)
        }else {
            return try HTTP.GET(url)
        }
    }
}
