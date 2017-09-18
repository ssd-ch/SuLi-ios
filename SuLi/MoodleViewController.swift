//
//  MoodleViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/12.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MoodleViewContoller : UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    let link = NSLocalizedString("moodle", tableName: "ResourceAddress", comment: "MoodleのURL")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: link) {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
        
        //バナー広告
        self.bannerView.adUnitID = NSLocalizedString("banner-id", tableName: "ResourceAddress", comment: "バナーID")
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
}
