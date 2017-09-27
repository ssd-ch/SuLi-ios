//
//  MoodleViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/12.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MoodleViewContoller : UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
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
        self.bannerView.delegate = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("MoodleViewContoller : load display")
        
        //バナー広告
        if UserDefaults.standard.bool(forKey: SettingViewContoller.adsDisplay) {
            self.bannerView.isAutoloadEnabled = true
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
        else {
            self.bannerView.isAutoloadEnabled = false
            self.bannerViewHeightConstraint.constant = 0
            self.bannerView.isHidden = true
        }
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if UserDefaults.standard.bool(forKey: SettingViewContoller.adsDisplay) {
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("MoodleViewContoller : \(error.localizedDescription)")
        self.bannerViewHeightConstraint.constant = 0
        self.bannerView.isHidden = true
    }
}
