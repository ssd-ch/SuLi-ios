//
//  sjisHTTP.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/06.
//  Copyright © 2017年 ssd. All rights reserved.
//

import Foundation
import Alamofire

public class sjisHTTP {
    
    open class func GET(_ url: String, parameters: [String:String]? = nil) throws -> DataRequest  {
        let manager = RequestManager.manager()
        if parameters != nil {
            var sjisURL: String = url + "?"
            for (key, value) in parameters!{
                sjisURL.append("\(key)=\(value.sjisPercentEncoded)&")
            }
            return manager.request(sjisURL, method: .get)
        }else {
            return manager.request(url, method: .get)
        }
    }
}
