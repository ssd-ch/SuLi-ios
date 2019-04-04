//
//  ShareFileViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/26.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient
import GoogleMobileAds

class ShareFileViewController : UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    var atPath = ""
    var destinationPath: String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //プログレスバーを0にセットする
        self.progressView.setProgress(0.0, animated: false)
        
        SMBSessionController.downloadTask = SMBSessionController.session?.downloadTaskForFile(atPath: self.atPath, destinationPath: nil, progressHandler: {(totalBytesWritten, totalBytesExpected) in
            let progress = Float(totalBytesWritten) / Float(totalBytesExpected)
            print("ShareFileView : downloaded " + String(format: "%.2f", progress * 100) + "%")
            DispatchQueue.main.async {
                self.progressView.setProgress(progress, animated: true)
            }
        },completionHandler: { filepath in
            print("ShareFileView : File was downloaded to \(filepath!)")
            //メインスレッドで呼び出す
            DispatchQueue.main.async {
                if let url = URL(string: filepath!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) {
                    print("ShareFileView : webview load request")
                    let request = URLRequest(url: url)
                    self.webView.loadRequest(request)
                    
                    self.destinationPath = filepath!
                    
                    //プログレスバーを隠す
                    self.progressView.isHidden = true
                }
                else {
                    print("ShareFileView : invalidation url")
                }
            }
        }, failHandler: { error in
            print("ShareFileView : \(String(describing: error?.localizedDescription))")
        })
        SMBSessionController.downloadTask?.resume()
        
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
        print("ShareFileViewController : load display")
        
        //バナー広告
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.adsDisplay) {
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
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.adsDisplay) {
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("ShareFileViewController : \(error.localizedDescription)")
        self.bannerViewHeightConstraint.constant = 0
        self.bannerView.isHidden = true
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            print("ShareFileView : back to parent view controller")
            if self.destinationPath != nil {
                do {
                    try FileManager.default.removeItem(atPath: self.destinationPath!)
                    print("ShareFileView : delete \(self.destinationPath!)")
                } catch {
                    print("ShareFileView : failed delete \(self.destinationPath!)")
                }
            }
            else {
                SMBSessionController.downloadTask?.cancel()
                print("ShareFileView : canceled download task")
            }
        }
    }
}
