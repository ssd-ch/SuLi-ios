//
//  SettingViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/09/17.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class SettingViewContoller : UITableViewController {
    
    @IBOutlet weak var switchDataSync: UISwitch!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var switchAdsDisplay: UISwitch!
    
    // UserDefaultsを使って値を保持する
    private let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.switchDataSync.isOn = self.userDefault.bool(forKey: UserDefaultsKey.dataSync)
        self.switchAdsDisplay.isOn = self.userDefault.bool(forKey: UserDefaultsKey.adsDisplay)
        
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.versionLabel!.text = appVersion
        }
        else {
            self.versionLabel!.text = "0.0"
        }
    }
    
    //自動データ同期のスイッチの値を変更した時に呼ばれる
    @IBAction func changeDataSync(_ sender: UISwitch) {
        self.userDefault.set(sender.isOn, forKey: UserDefaultsKey.dataSync)
    }
    
    //広告表示の値を変更した時に呼ばれる
    @IBAction func changeAdsDisplay(_ sender: UISwitch) {
        self.userDefault.set(sender.isOn, forKey: UserDefaultsKey.adsDisplay)
    }
    
}
