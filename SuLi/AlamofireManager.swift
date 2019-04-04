//
//  AlamofireManager.swift
//  SuLi
//
//  Created by ssd_ch on 2019/04/04.
//  Copyright © 2019 ssd. All rights reserved.
//

import Alamofire

public class RequestManager {
    
    static let http_manager: SessionManager = generateManager()
    
    private class func generateManager() -> SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let manager = SessionManager(configuration: configuration)
        return manager
    }
    
    open class func manager() -> SessionManager {
        return RequestManager.http_manager
    }
    
}
