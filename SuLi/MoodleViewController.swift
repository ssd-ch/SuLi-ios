//
//  MoodleViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/12.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class MoodleViewContoller : UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    let link = NSLocalizedString("moodle", tableName: "ResourceAddress", comment: "MoodleのURL")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: link) {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }
}
