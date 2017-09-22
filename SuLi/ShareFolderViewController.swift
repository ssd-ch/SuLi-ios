//
//  ShareFolderViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/21.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient
import GoogleMobileAds

class ShareFolderViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    var path = NSLocalizedString("shareStorage-rootPath", tableName: "ResourceAddress", comment: "共有ストレージの最初に表示する階層")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    var files:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SMBSessionController.session?.requestContentsOfDirectory( atFilePath: self.path, success: { data in
            self.files = data
            
            //テーブルビューデリゲート
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.reloadData()
        }, error: { error in
            print(error!.localizedDescription)
            //アラートを作成
            let alert = MyAlertController.action(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: error!.localizedDescription)
            //アラートを表示
            self.present(alert, animated: true, completion: nil)
        })
        
        //self.files = try! SMBSessionController.session?.requestContentsOfDirectory(atFilePath: self.path)
        
        //バナー広告
        self.bannerView.adUnitID = NSLocalizedString("banner-id", tableName: "ResourceAddress", comment: "バナーID")
        self.bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ShareFolderViewController : load display")
        
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
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("ShareFolderViewController : \(error.localizedDescription)")
        self.bannerViewHeightConstraint.constant = 0
        self.bannerView.isHidden = true
    }
    
    // セルの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files!.count
    }
    
    // セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = (self.files?[indexPath.row] as! TOSMBSessionFile).name
        return cell
    }
    
    // セルが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //フォルダとファイルで遷移するビューを切り替える
        if (self.files?[indexPath.row] as! TOSMBSessionFile).directory {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareFolderView") as! ShareFolderViewContoller
            nextViewController.path = (self.files?[indexPath.row] as! TOSMBSessionFile).filePath
            nextViewController.navigationItem.title = (self.files?[indexPath.row] as! TOSMBSessionFile).name
            self.show(nextViewController, sender: nil)
        }
        else {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareFileView") as! ShareFileViewController
            nextViewController.atPath = (self.files?[indexPath.row] as! TOSMBSessionFile).filePath
            nextViewController.navigationItem.title = (self.files?[indexPath.row] as! TOSMBSessionFile).name
            self.show(nextViewController, sender: nil)
        }
    }
}
