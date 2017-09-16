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
    
    //設定の状態を取得するためのキー
    static let dataSync = "dataSync"
    
    // UserDefaultsを使って値を保持する
    private let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.switchDataSync.isOn = self.userDefault.bool(forKey: SettingViewContoller.dataSync)
    }
    
    //自動データ同期のスイッチの値を変更した時に呼ばれる
    @IBAction func changeDataSync(_ sender: UISwitch) {
        self.userDefault.set(sender.isOn, forKey: SettingViewContoller.dataSync)
    }
    
}
