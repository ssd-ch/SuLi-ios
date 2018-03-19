//
//  DeveloperViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/09/17.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class DeveloperViewContoller : UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    let link = NSLocalizedString("ssd_ch", tableName: "ResourceAddress", comment: "ssd-chのURL")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: link) {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }
}
